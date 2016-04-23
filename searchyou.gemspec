# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'searchyou/version'

Gem::Specification.new do |spec|
  spec.name          = "searchyou"
  spec.version       = Searchyou::VERSION
  spec.authors       = ["Nick Zadrozny"]
  spec.email         = ["nick@beyondthepath.com"]

  spec.summary       = %q{Add Elasticsearch to your Jekyll pages!}
  spec.description   = <<-EOF
                          The searchyou gem indexes your content to a predefined
                          Elasticsearch cluster. This allows you to provide a
                          blazing fast, customizeable search backend to your site.
                       EOF
  spec.homepage      = "https://bonsai.io/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", '~> 0'
  spec.add_development_dependency "jekyll", '~> 0'
  #spec.add_dependency "elasticsearch-ruby", '~> 1'
  spec.add_dependency "elasticsearch", '~> 1'
end
