require 'searchyou/indexer'

module Searchyou

  class Generator < Jekyll::Generator
    safe true
    priority :lowest

    def self.elasticsearch_url(site)
      ENV['ELASTICSEARCH_URL'] ||
      ENV['BONSAI_URL'] ||
      site.config['elasticsearch']['url']
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
    end
  end

end
