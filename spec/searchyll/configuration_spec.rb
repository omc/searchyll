require File.expand_path('../spec_helper', File.dirname(__FILE__))
require "jekyll"

class TestSite
  attr_accessor :config
  def initialize(config)
    @config = config
  end
end

describe Searchyll::Configuration do

  it 'is expected to return true when production and flag not set' do
    site_config = {
      'environment' => 'production',
      'elasticsearch' => {
        'production_only' => false
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
      }
    }
    site = TestSite.new site_config
    conf = Searchyll::Configuration.new site
    expect(conf.elasticsearch_production_only?).to eq(true)
  end

  it 'is expected to return false when not production and flag is not set' do
    site_config = {
      'environment' => 'not_production',
      'elasticsearch' => {
        'production_only' => false
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
        'production_only' => false
      }
    }
    site = TestSite.new site_config
    conf = Searchyll::Configuration.new site
    expect(conf.elasticsearch_production_only?).to eq(false)
  end
end
