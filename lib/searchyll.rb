require "searchyll/version"
require "jekyll/hooks"
require "jekyll/plugin"
require "jekyll/generator"
require "searchyll/configuration"
require "searchyll/indexer"
require "nokogiri"

begin
  indexers = {}

  Jekyll::Hooks.register(:site, :pre_render) do |site|
    config = Searchyll::Configuration.new(site)
    if config.elasticsearch_url && !config.elasticsearch_url.empty?
      puts "setting up indexer hook with url #{config.elasticsearch_url.inspect}"
      indexers[site] = Searchyll::Indexer.new(config)
      indexers[site].start
    else
      puts 'No ElasticSearch URL provided, skipping indexing...'
    end
  end

  Jekyll::Hooks.register :site, :post_render do |site|
    if (indexer = indexers[site])
      indexer.finish
    end
  end

  # gets random pages like your home page
  Jekyll::Hooks.register :pages, :post_render do |page|
    # strip html
    nokogiri_doc = Nokogiri::HTML(page.output)
    if page.data["searchyll_index"] == true
      if (indexer = indexers[page.site])
        puts %(        indexing page #{page.url})
        indexer << page.data.merge({
          id:     page.name,
          url:    page.url,
          text:   nokogiri_doc.xpath("//*[@index]//text()").to_s.gsub(/\s+/, " ")
        })
      end
    end
  end

  # gets both posts and collections
  Jekyll::Hooks.register :documents, :post_render do |document|
    # strip html
    nokogiri_doc = Nokogiri::HTML(document.output)

    if document.data["searchyll_index"] == true
      if (indexer = indexers[document.site])
        puts %(        indexing document #{document.url})
        indexer << document.data.merge({
          id:     document.id,
          url:    document.url,
          text:   nokogiri_doc.xpath("//*[@index]//text()").to_s.gsub(/\s+/, " ")
        })
      end
    end
  end

rescue => e
  puts e.message
end
