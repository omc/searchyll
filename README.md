# Searchyou

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/searchyou`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'searchyou'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install searchyou

## Usage

```
elasticsearch:
  url: "http://localhost:9200/" # Required. Supports auth and SSL: https://user:pass@someurl.com
                                # Can also read URLs stored in environment variable named
                                # BONSAI_URL and ELASTICSEARCH_URL.
  number_of_shards: 1           # Optional. Default is 1 primary shard.
  number_of_replicas: 1         # Optional. Default is 0 replicas.
  index_name: "jekyll"          # Optional. Default is "jekyll".
  default_type: "post"          # Optional. Default type is "post".
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/searchyou.
