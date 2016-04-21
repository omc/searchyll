require "searchyou/version"
require "net/http"
require "json"

module Jekyll

  class SearchyouIndexer < Jekyll::Generator
    safe true
    priority :lowest

    def generate(site)

      indexer = Searchyou::Indexer.new(site)
      indexer.run!

      site.posts.docs.each do |doc|
        indexer << doc.data.merge({
          id: doc.basename_without_ext,
          content: doc.content
        })
      end

      indexer.done!
    end
  end

end
