module Searchyou
  class Indexer
    require "elasticsearch"

    BATCH_SIZE = 50

    attr_accessor :es, :indexer_thread, :queue, :site, :timestamp, :working

    def initialize(site)
      self.site = site
      self.queue = Queue.new
      self.working = true
      self.timestamp = Time.now
      self.es = Elasticsearch::Client.new(
        url: site.config['elasticsearch']['url']
      )
    end

    def <<(doc)
      self.queue << doc
    end

    def working?
      working || queue.length > 0
    end

    def es_index_name
      "jekyll-#{timestamp.strftime('%Y%m%d%H%M%S')}"
    end

    # Prepare our indexing run by creating a new index.
    def prepare!
      es.indices.create(
        index: es_index_name
      )
      # todo: mapping?
      # settings: default is 5x1 sharding
      # set refresh interval to -1
      # set replication to 0?
    end

    def run!
      prepare!
      self.indexer_thread = Thread.new do
        loop do
          break unless working?
          es_bulk_insert!(current_batch)
        end
      end
    end

    def es_bulk_insert!(batch)
      es.bulk body: batch
    end

    def current_batch
      count = 0
      batch = []
      while count < BATCH_SIZE && queue.length > 0 && working?
        batch << queue.pop
        count += 1
      end
      batch
    end

    def done!
      self.working = false
      indexer_thread.join
      finalize!
    end

    def finalize!
      # post /_refresh
      # update alias
      # cleanup old indices?
    end

  end
end
