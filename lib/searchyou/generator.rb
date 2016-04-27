require 'searchyou/indexer'

module Searchyou

  # Allow access to Searchyou.configuration hash
  class << self
    attr_accessor :configuration
  end

  class Generator < Jekyll::Generator

    safe true
    priority :lowest

    # Public: Invoked by Jekyll during the generation phase.
    def generate(site)

      # Gather the configuration options
      Searchyou.configure(site)

      # Prepare the indexer
      indexer = Searchyou::Indexer.new(Searchyou.configuration.url)
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

  # Create a configuration for the site
  def self.configure(site)
    self.configuration ||= Configuration.new(site)
  end

  class Configuration
    attr_accessor :url, :number_of_shards, :number_of_replicas, :index_name, :default_type

    def initialize(site)

      # Figure out the Elasticsearch URL, from an environment variable or the
      # Jekyll site configuration. Raises an exception if none is found, so we
      # can skip the indexing.
      @url = ENV['BONSAI_URL'] || ENV['ELASTICSEARCH_URL'] ||
              ((site.config||{})['elasticsearch']||{})['url'] ||
              raise(ArgumentError, "No Elasticsearch URL present, skipping indexing")

      # Get the rest of the config options, or use the defaults:
      @number_of_shards = site.config['elasticsearch']['number_of_shards'] || 1
      @number_of_replicas = site.config['elasticsearch']['number_of_replicas'] || 1
      @index_name = site.config['elasticsearch']['index_name'] || "jekyll"
      @default_type = site.config['elasticsearch']['default_type'] || 'post'
    end
  end
end
