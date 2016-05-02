require File.expand_path('../spec_helper', File.dirname(__FILE__))

describe Searchyll::Generator do

  it 'is a Jekyll Generator' do
    expect(Searchyll::Generator.new).to be_a(Jekyll::Generator)
  end

  let(:jekyll_site) do
    double(
      'jekyll site',
      config: { 'elasticsearch' => { 'url' => 'http://localhost:9200' }}
    )
  end

  # TODO: integrated site generation
  it 'can generate an index' do
    g = Searchyll::Generator.new
    g.generate(jekyll_site)
  end

end
