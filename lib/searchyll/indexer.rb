require 'json'
require 'net/http'

module Searchyll
  class Indexer
    BATCH_SIZE = 50

    attr_accessor :configuration
    attr_accessor :indexer_thread
    attr_accessor :queue
    attr_accessor :timestamp
    attr_accessor :uri
    attr_accessor :working

    def initialize(configuration)
      self.configuration = configuration
      self.uri = URI(configuration.elasticsearch_url)
      self.queue = Queue.new
      self.working = true
      self.timestamp = Time.now
    end

    # Public: Add new documents for batch indexing.
    def <<(doc)
      queue << doc
    end

    # Signal a stop condition for our batch indexing thread.
    def working?
      working || !queue.empty?
    end

    # A versioned index name, based on the time of the indexing run.
    # Will be later added to an alias for hot reindexing.
    def elasticsearch_index_name
      "#{configuration.elasticsearch_index_base_name}-#{timestamp.strftime('%Y%m%d%H%M%S')}"
    end

    # Prepare an HTTP connection
    def http_start
      http = Net::HTTP.start(
        uri.hostname, uri.port,
        use_ssl: (uri.scheme == 'https')
      )
      yield(http)
    end

    # Prepare our indexing run by creating a new index.
    def prepare_index
      create_index = http_put("/#{elasticsearch_index_name}")
      create_index.body = {
        index: {
          number_of_shards:   configuration.elasticsearch_number_of_shards,
          number_of_replicas: 0,
          refresh_interval:   -1
        }
      }.to_json # TODO: index settings

      http_start do |http|
        http.request(create_index)
      end

      # TODO: mapping?
    end

    # Public: start the indexer and wait for documents to index.
    def start
      prepare_index

      self.indexer_thread = Thread.new do
        http_start do |http|
          loop do
            break unless working?
            es_bulk_insert!(http, current_batch)
          end
        end
      end
    end

    def http_put(path)
      http_request(Net::HTTP::Put, path)
    end

    def http_post(path)
      http_request(Net::HTTP::Post, path)
    end

    def http_get(path)
      http_request(Net::HTTP::Get, path)
    end

    def http_delete(path)
      http_request(Net::HTTP::Delete, path)
    end

    def http_request(klass, path)
      req = klass.new(path)
      req.content_type = 'application/json'
      req['Accept']    = 'application/json'
      # Append auth credentials if the exist
      req.basic_auth(uri.user, uri.password) if uri.user.present? && uri.password.present?
      req
    end

    # Given a batch (array) of documents, index them into Elasticsearch
    # using its Bulk Update API.
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html
    def es_bulk_insert!(http, batch)
      bulk_insert = http_post("/#{elasticsearch_index_name}/#{configuration.elasticsearch_default_type}/_bulk")
      bulk_insert.body = batch.map do |doc|
        [{ index: {} }.to_json, doc.to_json].join("\n")
      end.join("\n") + "\n"
      http.request(bulk_insert)
    end

    # Fetch a batch of documents from the queue. Returns a maximum of BATCH_SIZE
    # documents.
    def current_batch
      count = 0
      batch = []
      while count < BATCH_SIZE && !queue.empty?
        batch << queue.pop
        count += 1
      end
      batch
    end

    # Public: Indicate to the indexer that no new documents are being added.
    def finish
      self.working = false
      indexer_thread.join
      finalize!
    end

    # List the indices currently in the cluster, caching the call in an ivar
    def old_indices
      return if defined?(@old_indices)
      resp = http_start { |h| h.request(http_get('/_cat/indices?h=index')) }
      indices = JSON.parse(resp.body).map { |i| i['index'] }
      indices = indices.select { |i| i =~ /\A#{configuration.elasticsearch_index_base_name}/ }
      indices -= [elasticsearch_index_name]
      @old_indices = indices
    end

    # Once documents are done being indexed, finalize the process by adding
    # the new index into an alias for searching.
    def finalize!
      # run the prepared requests
      http_start do |http|
        finalize_refresh(http)
        finalize_replication(http)
        finalize_aliases(http)
        finalize_cleanup(http)
      end
    end

    # refresh the index to make it searchable
    def finalize_refresh(http)
      refresh = http_post("/#{elasticsearch_index_name}/_refresh")
      http.request(refresh)
    end

    # add replication to the new index
    def finalize_replication(http)
      add_replication = http_put("/#{elasticsearch_index_name}/_settings")
      add_replication.body = {
        index: {
          number_of_replicas: configuration.elasticsearch_number_of_replicas
        }
      }.to_json
      http.request(add_replication)
    end

    # hot swap the index into the canonical alias
    def finalize_aliases(http)
      update_aliases = http_post('/_aliases')
      update_aliases.body = {
        actions: [
          { remove: {
            index: old_indices.join(','),
            alias: configuration.elasticsearch_index_base_name
          } },
          { add: {
            index: elasticsearch_index_name,
            alias: configuration.elasticsearch_index_base_name
          } }
        ]
      }.to_json
      http.request(update_aliases)
    end

    # delete old indices after a successful reindexing run
    def finalize_cleanup(http)
      return if old_indices.empty?
      cleanup_indices = http_delete("/#{old_indices.join(',')}")
      puts %(       Old indices: #{old_indices.join(', ')})
      http.request(cleanup_indices)
    end
  end
end
