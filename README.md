# Searchyll

Searchyll is a ruby gem that indexes Jekyll posts to a given Elasticsearch cluster URL.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'searchyll'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install searchyll

## Usage

In config.yml:
```
gems: [searchyll]

elasticsearch:
  url: "http://localhost:9200/" # Required. Supports auth and SSL: https://user:pass@someurl.com
                                # Can also read URLs stored in environment variable named
                                # BONSAI_URL and ELASTICSEARCH_URL.
  number_of_shards: 1           # Optional. Default is 1 primary shard.
  number_of_replicas: 1         # Optional. Default is 0 replicas.
  index_name: "jekyll"          # Optional. Default is "jekyll".
  default_type: "post"          # Optional. Default type is "post".
```

Index your Jekyll site locally by running `$ BONSAI_URL=[YOUR_ELASTICSEARCH_CLUSTER_URL] jekyll build`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/searchyll.
