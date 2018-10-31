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

    # Getter for the alias name
    def elasticsearch_alias_name
      site.config['elasticsearch']['alias_name'] || "jekyll"
    end

    # Getter for the default type
    def elasticsearch_default_type
      site.config['elasticsearch']['default_type'] || 'post'
    end

    # Getter for the mapping fields file's path value
    def elasticsearch_analysis_fields
      site.config['elasticsearch']['analysis_file_path'] || nil
    end
    # Getter for the analysis fields file's path value
    def elasticsearch_mapping_fields
      site.config['elasticsearch']['mapping_file_path'] || nil
    end
  end
end
