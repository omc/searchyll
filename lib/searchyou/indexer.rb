module Searchyou
  class Indexer

    BATCH_SIZE = 50

    attr_accessor :queue
    attr_accessor :working
    attr_accessor :elasticsearch_url
    attr_accessor :timestamp
    attr_accessor :indexer_thread

    def initialize(elasticsearch_url)
      self.elasticsearch_url = elasticsearch_url
      self.queue = Queue.new
      self.working = true
      self.timestamp = Time.now
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
    def prepare_index
      # es.indices.create(
      #   index: es_index_name
      # )
      # todo: mapping?
      # set refresh interval to -1
      # set replication to 0?
    end

    def start
      prepare_index

      self.indexer_thread = Thread.new do
        loop do
          break unless working?
          es_bulk_insert!(current_batch)
        end
      end
    end

    def es_bulk_insert!(batch)
      # es
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

    def finish
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
