require File.expand_path('../spec_helper', File.dirname(__FILE__))
require "jekyll"

describe Searchyll::Configuration do

  it 'is expected to return true when production and flag not set' do
    site_config = {
      'environment' => 'production',
      'elasticsearch' => {
        'production_only' => false
      },
      'source' => __dir__,
      'destination' => __dir__,
      'cache_dir' => __dir__,
      'permalink' => __dir__,
      'liquid' => {
        'error_mode' => false
      }
    }
    site = TestSite.new site_config
    conf = Searchyll::Configuration.new site
    expect(conf.elasticsearch_production_only?).to eq(true)
  end

  it 'is expected to return true when production and flag is set' do
    site_config = {
      'environment' => 'production',
      'elasticsearch' => {
        'production_only' => true
      },
      'source' => __dir__,
      'destination' => __dir__,
      'cache_dir' => __dir__,
      'permalink' => __dir__,
      'liquid' => {
        'error_mode' => false
      }
    }
    site = TestSite.new site_config
    conf = Searchyll::Configuration.new site
    expect(conf.elasticsearch_production_only?).to eq(true)
  end

  it 'is expected to return false when not production and flag is set' do
    site_config = {
      'environment' => 'not_production',
      'elasticsearch' => {
        'production_only' => true
      },
      'source' => __dir__,
      'destination' => __dir__,
      'cache_dir' => __dir__,
      'permalink' => __dir__,
      'liquid' => {
        'error_mode' => false
      }
    }
    site = TestSite.new site_config
    conf = Searchyll::Configuration.new site
    expect(conf.elasticsearch_production_only?).to eq(false)
  end

  it 'is expected to return false when not production and flag is not set' do
    site_config = {
      'environment' => 'not_production',
      'elasticsearch' => {
        'production_only' => false
      },
      'source' => __dir__,
      'destination' => __dir__,
      'cache_dir' => __dir__,
      'permalink' => __dir__,
      'liquid' => {
        'error_mode' => false
      }
    }
    site = TestSite.new site_config
    conf = Searchyll::Configuration.new site
    expect(conf.elasticsearch_production_only?).to eq(false)
  end
end
