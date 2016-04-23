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

    def es_index_prefix
      site.config['elasticsearch']['index_name'] || "jekyll"
    end

    def es_index_name
      "#{es_index_prefix}-#{timestamp.strftime('%Y%m%d%H%M%S')}"
    end

    def number_of_shards
      site.config['elasticsearch']['number_of_shards'] || 1
    end

    def number_of_replicas
      site.config['elasticsearch']['number_of_replicas'] || 0
    end

    # Prepare our indexing run by creating a new index.
    def prepare!
      es.indices.create(
        index: es_index_name,
        body: {
          settings: {
            index: {
              number_of_shards: number_of_shards,
              number_of_replicas: number_of_replicas,
              refresh_interval: "-1"
            }
          }
        }
      )
      # todo: mapping?
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

      # Update refresh interval
      es.indices.put_settings index: es_index_name, body: {
        index: {
          refresh_interval: "1s"
        }
      }

      # Update Alias
      es.indices.update_aliases body: {
        actions: [
          { add: { index: es_index_name, alias: es_index_prefix } }
        ]
      }

      # Clean up old indices:
      indices = []
      es.cat.indices(index: "#{es_index_prefix}-*", h: 'i', format: 'json').each do |i|
        indices << i["i"] unless i["i"] == es_index_name
      end
      es.indices.delete index: indices.join(",") unless indices.empty?
    end

  end
end
