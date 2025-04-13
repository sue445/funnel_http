# FunnelHttp
Perform HTTP requests in parallel with goroutine

[![Gem Version](https://badge.fury.io/rb/funnel_http.svg)](https://badge.fury.io/rb/funnel_http)
[![build](https://github.com/sue445/funnel_http/actions/workflows/build.yml/badge.svg)](https://github.com/sue445/funnel_http/actions/workflows/build.yml)

## Requirements
* Ruby
* Go

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add funnel_http
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install funnel_http
```

## Usage
Use [`FunnelHttp::Client#perform`](https://sue445.github.io/funnel_http/FunnelHttp/Client.html#perform-instance_method)

```ruby
require "funnel_http"

client = FunnelHttp::Client.new

requests = [
  {
    method: :get,
    url: "https://example.com/api/user/1",
  },

  # with request header
  {
    method: :get,
    url: "https://example.com/api/user/2",
    header: {
      "Authorization" => "Bearer xxxxxxxx",
      "X-Multiple-Values" => ["1st value", "2nd value"],
    },
  },

  # with request body
  {
    method: :post,
    url: "https://example.com/api/user",
    header: {
      "Authorization" => "Bearer xxxxxxxx",
      "Content-Type" => "application/json",
    },
    body: '{"name": "sue445"}',
  },
]

responses = client.perform(requests)
# => [
#   { url: "https://example.com/api/user/1", status_code: 200, body: "Response of /api/user/1", header: { "Content-Type" => ["text/plain;charset=utf-8"]} }
#   { url: "https://example.com/api/user/2", status_code: 200, body: "Response of /api/user/2", header: { "Content-Type" => ["text/plain;charset=utf-8"]} }
#   { url: "https://example.com/api/user", status_code: 200, body: "Response of /api/user", header: { "Content-Type" => ["text/plain;charset=utf-8"]} }
# ]

# `#perform!` raise errors when http requests returns error status code (4xx, 5xx)
responses = client.perform!(requests)
```

## Customize
### Add default header
Example1. Pass default header to [`FunnelHttp::Client#initialize`](https://sue445.github.io/funnel_http/FunnelHttp/Client.html#normalize_requests-instance_method)

```ruby
default_header = { "Authorization" => "Bearer xxxxxx" }

client = FunnelHttp::Client.new(default_header)
```

Example 2. Use [`FunnelHttp::Client#add_default_request_header`](https://sue445.github.io/funnel_http/FunnelHttp/Client.html#add_default_request_header-instance_method)

```ruby
client.add_default_request_header("Authorization", "Bearer xxxxxx")
```

## API Reference
https://sue445.github.io/funnel_http/

## Performance
Depending on the case, `funnel_http` runs about 1.2x faster than pure-Ruby `Thread` :dash:

See [benchmark/](benchmark/)

### Why?
`funnel_http` uses [Go's goroutine](https://go.dev/tour/concurrency) for asynchronous processing of HTTP requests.

So this is faster than Ruby in many cases.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sue445/funnel_http.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
