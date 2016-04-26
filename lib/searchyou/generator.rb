require 'searchyou/indexer'

module Searchyou

  class Generator < Jekyll::Generator
    safe true
    priority :lowest

    def self.abort(msg)
      $stderr.puts(msg)
    end

    def self.elasticsearch_url(site)
      ENV['ELASTICSEARCH_URL'] ||
      ENV['BONSAI_URL'] ||
      ((site.config||{})['elasticsearch']||{})['url'] ||
      raise(ArgumentError, "No Elasticsearch URL present, skipping indexing")
    end

    def generate(site)
      url = self.class.elasticsearch_url(site)
      indexer = Searchyou::Indexer.new(site)
      indexer.start

      site.posts.docs.each do |doc|
        indexer << doc.data.merge({
          id: doc.basename_without_ext,
          content: doc.content
        })
      end

      indexer.finish
    rescue => e
      $stderr.puts "Searchyll: #{e.class.name} - #{e.message}"
    end
  end

end
