require File.expand_path('../spec_helper', File.dirname(__FILE__))
require "jekyll"

class TestSite
  attr_accessor :config
  def initialize(config)
    @config = config
  end
end

describe Searchyll::Configuration do

  it 'is expected to return true when production no environment spessified' do
    site_config = {
      'environment' => 'production',
      'elasticsearch' => {
      }
    }
    site = TestSite.new site_config
    conf = Searchyll::Configuration.new site
    expect(conf.should_execute_in_current_environment?).to eq(true)
  end

  it 'is expected to return true when production and environment is nil' do
    site_config = {
      'environment' => 'production',
      'elasticsearch' => {
        'environments' => nil
      }
    }
    site = TestSite.new site_config
    conf = Searchyll::Configuration.new site
    expect(conf.should_execute_in_current_environment?).to eq(true)
  end

  it 'is expected to return true when production and environment is not a array' do
    site_config = {
      'environment' => 'production',
      'elasticsearch' => {
        'environments' => true
      }
    }
    site = TestSite.new site_config
    conf = Searchyll::Configuration.new site
    expect(conf.should_execute_in_current_environment?).to eq(true)
  end

  it 'is expected to return false when production and different environment spessified' do
    site_config = {
      'environment' => 'production',
      'elasticsearch' => {
        'environments' => ['dev']
      }
    }
    site = TestSite.new site_config
    conf = Searchyll::Configuration.new site
    expect(conf.should_execute_in_current_environment?).to eq(false)
  end

  it 'is expected to return true when production and several environment spessified' do
    site_config = {
      'environment' => 'production',
      'elasticsearch' => {
        'environments' => ['dev', 'test', 'stage', 'production']
      }
    }
    site = TestSite.new site_config
    conf = Searchyll::Configuration.new site
    expect(conf.should_execute_in_current_environment?).to eq(true)
  end
  
end
