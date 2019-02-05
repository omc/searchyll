# Searchyll

Search for Jekyll apps. A plugin for indexing your pages into a search engine.

Currently supports Elasticsearch, we're also considering modular support for
Apache Solr in a future release.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'searchyll'
```

In your Jekyll Gemfile:

```
gems:
  - searchyll
```

## Configuration

```yaml
elasticsearch:
  url: "http://localhost:9200/"     # Required. Supports auth and SSL: https://user:pass@someurl.com
                                    # Can also read URLs stored in environment variable named
                                    # BONSAI_URL and ELASTICSEARCH_URL.
  number_of_shards: 1               # Optional. Default is 1 primary shard.
  number_of_replicas: 1             # Optional. Default is 1 replica.
  index_name: "jekyll"              # Optional. Default is "jekyll".
  default_type: "post"              # Optional. Default type is "post".
  custom_settings: _es_settings.yml # Optional. No default. Relative to your src folder
  custom_mappings: _es_mappings.yml # Optional. No default. Relative to your src folder
  ignore:                           # Optional. No default.
    - /news/*
```

### Custom Settings File Example

It should be written to be plugged into the `settings` slot of a [create index](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) call

```yaml
analysis:
  analyzer:
    stop_analyzer:
      type: stop
      stopwords: _english_
index:
  number_of_shards: 1
  number_of_replicas: 0
```

### Custom Mappings File Example

It should be written to be plugged into the `mappings.[type]` slot of a [create index](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) call

```yaml
properties:
  field1:
    type: text
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/omc/searchyll
