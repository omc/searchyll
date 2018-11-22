module Searchyll
  class Configuration
    attr_accessor :site

    def initialize(site)
      self.site = site
    end

    # Determine a URL for the cluster, or fail with error
    def elasticsearch_url
      ENV['BONSAI_URL'] || ENV['ELASTICSEARCH_URL'] ||
        ((site.config||{})['elasticsearch']||{})['url']
    end

    def valid?
      elasticsearch_url && !elasticsearch_url.empty? && elasticsearch_url.start_with?('http')
    end

    def reasons
      reasons = []
      if elasticsearch_url && elasticsearch_url.empty?
        reasons << 'No Elasticsearch url configured'
        reasons << '  Looked in ENV[BONSAI_URL]'
        reasons << '  Looked in ENV[ELASTICSEARCH_URL]'
        reasons << '  Looked in _config.elasticsearch.url'
      elsif ! elasticsearch_url.start_with? 'http'
        reasons << "Elasticsearch url must start with 'http' or 'https'"
        reasons << "  Current Value: #{elasticsearch_url}"
        reasons << "  Current Source: #{elasticsearch_url_source}"
      end

      reasons
    end

    def elasticsearch_url_source
      if ENV['BONSAI_URL']
        'ENV[BONSAI_URL]'
      elsif ENV['ELASTICSEARCH_URL']
        'ENV[ELASTICSEARCH_URL]'
      elsif ((site.config||{})['elasticsearch']||{})['url']
        'CONFIG'
      else
        'NOT FOUND'
      end
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
