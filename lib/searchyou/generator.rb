require 'searchyou/indexer'

module Searchyou

  class Generator < Jekyll::Generator

    safe true
    priority :lowest

    # Public: Invoked by Jekyll during the generation phase.
    def generate(site)

      # Gather the configuration options
      configuration = Configuration.new(site)

      # Prepare the indexer
      indexer = Searchyou::Indexer.new(configuration)
      indexer.start

      # Iterate through the site contents and send to indexer
      # TODO: what are we indexing?
      site.posts.each do |doc|
        indexer << doc.data.merge({
          id: doc.id,
          content: doc.content
        })
      end

      # Signal to the indexer that we're done adding content
      indexer.finish

    # Handle any exceptions gracefully
    rescue => e
      $stderr.puts "Searchyll: #{e.class.name} - #{e.message}"
      $stderr.puts "Backtrace: #{e.backtrace.each{|l| puts l};nil}"
      raise(e)
    end

  end

  # Class containing configuration options
  class Configuration
    attr_accessor :site
    def initialize(site)
      self.site = site
    end

    # Determine a URL for the cluster, or fail with error
    def elasticsearch_url
      ENV['BONSAI_URL'] || ENV['ELASTICSEARCH_URL'] ||
        ((site.config||{})['elasticsearch']||{})['url'] ||
        raise(ArgumentError, "No Elasticsearch URL present, skipping indexing")
    end

    # Getter for the number of primary shards
    def elasticsearch_number_of_shards
      site.config['elasticsearch']['number_of_shards'] || 1
    end

    # Getter for the number of replicas
    def elasticsearch_number_of_replicas
      site.config['elasticsearch']['number_of_replicas'] || 1
    end

    # Getter for the index name
    def elasticsearch_index_base_name
      site.config['elasticsearch']['index_name'] || "jekyll"
    end

    # Getter for the default type
    def elasticsearch_default_type
      site.config['elasticsearch']['default_type'] || 'post'
    end
  end
end
