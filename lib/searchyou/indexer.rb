require 'json'
require 'net/http'

module Searchyou
  class Indexer

    BATCH_SIZE = 50

    attr_accessor :indexer_thread
    attr_accessor :queue
    attr_accessor :timestamp
    attr_accessor :uri
    attr_accessor :working

    def initialize(elasticsearch_url)
      self.uri = URI(elasticsearch_url)
      self.queue = Queue.new
      self.working = true
      self.timestamp = Time.now
    end

    # Public: Add new documents for batch indexing.
    def <<(doc)
      self.queue << doc
    end

    # Signal a stop condition for our batch indexing thread.
    def working?
      working || queue.length > 0
    end

    # A versioned index name, based on the time of the indexing run.
    # Will be later added to an alias for hot reindexing.
    # TODO: base index name should be configurable in the site.config.
    def es_index_name
      "jekyll-#{timestamp.strftime('%Y%m%d%H%M%S')}"
    end

    # Prepare an HTTP connection
    def http_start(&block)
      http = Net::HTTP.start(
        uri.hostname, uri.port,
        :use_ssl => (uri.scheme == 'https')
      )
      yield(http)
    end

    # Prepare our indexing run by creating a new index.
    # TODO: make the number of shards configurable or variable
    def prepare_index
      create_index = http_post("/#{es_index_name}")
      create_index.body = {
        index: {
          number_of_shards:   1,
          number_of_replicas: 0,
          refresh_interval:   -1
        }
      }.to_json # TODO: index settings

      http_start do |http|
        resp = http.request(create_index)
      end

      # todo: mapping?
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

    # Helper method for creating a Net::HTTP::Post to ES
    def http_post(path)
      req = Net::HTTP::Post.new(path)
      req.content_type = 'application/json'
      req.basic_auth(uri.user, uri.password)
      req
    end

    # Given a batch (array) of documents, index them into Elasticsearch
    # using its Bulk Update API.
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-bulk.html
    # TODO: choose a better type name, or make it configurable?
    def es_bulk_insert!(http, batch)
      bulk_insert = http_post("/#{es_index_name}/post/_bulk")
      bulk_insert.body = batch.map do |doc|
        [ { :index => {} }.to_json, doc.to_json ].join("\n")
      end.join("\n") + "\n"
      puts bulk_insert.body
      http.request(bulk_insert)
    end

    # Fetch a batch of documents from the queue. Returns a maximum of BATCH_SIZE
    # documents.
    def current_batch
      count = 0
      batch = []
      while count < BATCH_SIZE && queue.length > 0
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

    # Once documents are done being indexed, finalize the process by adding
    # the new index into an alias for searching.
    # TODO: cleanup old indices?
    def finalize!
      refresh = http_post("/#{es_index_name}/_refresh")

      update_aliases = http_post("/_aliases")
      update_aliases.body = {
        "actions": [
          { "remove": { "index": "*", "alias": "jekyll" }},
          { "add":    { "index": es_index_name, "alias": "jekyll" }}
        ]
      }.to_json

      http_start do |http|
        http.request(refresh)
        http.request(update_aliases)
      end
    end

  end
end
