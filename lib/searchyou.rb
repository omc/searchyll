require "searchyou/version"
require "searchyou/indexer"
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
        indexer << {
          index: {
            _index: indexer.es_index_name,
            _type: 'post',
            data: {
              content: doc.content
            }
          }
        }
      end
      indexer.done!
    end
  end

end
