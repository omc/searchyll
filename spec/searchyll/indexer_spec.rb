require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Searchyll::Indexer do

  it 'is instantiated with an Elasticsearch URL' do
    expect { Searchyll::Indexer.new }.to raise_error(ArgumentError)
  end

end
