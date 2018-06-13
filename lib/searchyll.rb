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
    indexers[site] = Searchyll::Indexer.new(config)
    indexers[site].start
  end

  Jekyll::Hooks.register :site, :post_render do |site|
    indexers[site].finish
  end

  Jekyll::Hooks.register [:documents], :post_render do |document|
    # strip html
    nokogiri_doc = Nokogiri::HTML(document.output)

    puts %(        indexing #{document.collection.label} #{document.data['title']})

    indexer = indexers[document.site]
    indexer << document.data.merge({
      id:     document.id,
      url:    document.url,
      text:   nokogiri_doc.xpath("//article//text()").to_s.gsub(/\s+/, " "),
      html:   document.content,
      type:   document.collection.label
    })
  end

rescue => e
  puts e.message
end
