require 'searchyou/indexer'

module Searchyou

  class Generator < Jekyll::Generator
    safe true
    priority :lowest

    # Public: Invoked by Jekyll during the generation phase.
    def generate(site)

      # Find the ES URL
      url = elasticsearch_url(site)

      # Prepare the indexer
      indexer = Searchyou::Indexer.new(url)
      indexer.start

      # Iterate through the site contents and send to indexer
      # TODO: what are we indexing?
      site.posts.each do |doc|
        puts doc.methods
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
      raise(e)
    end

    # Figure out the Elasticsearch URL, from an environment variable or the
    # Jekyll site configuration. Raises an exception if none is found, so we
    # can skip the indexing.
    def elasticsearch_url(site)
      ENV['BONSAI_URL'] || ENV['ELASTICSEARCH_URL'] ||
      ((site.config||{})['elasticsearch']||{})['url'] ||
      raise(ArgumentError, "No Elasticsearch URL present, skipping indexing")
    end

  end

end
