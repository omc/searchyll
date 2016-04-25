require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Searchyou::Indexer do

  it 'is instantiated with an Elasticsearch URL' do
    expect { Searchyou::Indexer.new }.to raise_error(ArgumentError)
  end

end
