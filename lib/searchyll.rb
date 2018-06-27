require "searchyll/version"
require "jekyll/hooks"
require "jekyll/plugin"
require "jekyll/generator"
require "searchyll/configuration"
require "searchyll/indexer"
require "nokogiri"
require "Time"

begin
  indexers = {}

  Jekyll::Hooks.register(:site, :pre_render) do |site|
    config = Searchyll::Configuration.new(site)
    indexers[site] = Searchyll::Indexer.new(config)
    indexers[site].start
  end

  Jekyll::Hooks.register :site, :post_render do |site|
    indexers[site].finish
  end

  # gets random pages like your home page
  Jekyll::Hooks.register :pages, :post_render do |page|
    # strip html
    nokogiri_doc = Nokogiri::HTML(page.output)

    puts %(        indexing page #{page.url})

    # parse date for Java date type: https://www.elastic.co/guide/en/elasticsearch/reference/current/date.html#date
    date = page.data["date"] ? Time.parse(page.data["date"].to_s).iso8601 : Time.now.iso8601
    
    # Prepare doc for elasticsearch
    page_data = page.data.merge!({
      "date" => date,
      "id" =>   page.name,
      "url" =>  page.url,
      "text" => nokogiri_doc.xpath("//article//text()").to_s.gsub(/\s+/, " ")
    })

    indexer = indexers[page.site]
    indexer << page_data
  end

  # gets both posts and collections
  Jekyll::Hooks.register :documents, :post_render do |document|
    # strip html
    nokogiri_doc = Nokogiri::HTML(document.output)

    puts %(        indexing document #{document.url})

    # parse date for Java date type: https://www.elastic.co/guide/en/elasticsearch/reference/current/date.html#date
    date = document.data["date"] ? Time.parse(document.data["date"].to_s).iso8601 : Time.now.iso8601

    # Prepare doc for elasticsearch
    document_data = document.data.merge!({
      "date" => date,
      "id"   => document.id,
      "url"  => document.url,
      "text" => nokogiri_doc.xpath("//article//text()").to_s.gsub(/\s+/, " ")
    })

    indexer = indexers[document.site]
    indexer << document_data
  end

rescue => e
  puts e.message
end
