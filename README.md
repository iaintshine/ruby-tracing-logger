[![Build Status](https://travis-ci.org/iaintshine/ruby-tracing-logger.svg?branch=master)](https://travis-ci.org/iaintshine/ruby-tracing-logger)

# Tracing::Logger

A simple implementation of Ruby's logger `Tracer::Logger` with support for OpenTracing Tracer as a destination. The gem includes additional `Tracing::CompositeLogger` thanks to which you can specify multiple destination loggers, each with different level and formatter. 

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tracing-logger'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tracing-logger

## Usage

To initialize a new instance of `Tracing::Logger` you need to specify at least an active span provider - a proc which returns a current active span. The gem plays nicely with [spanmanager](https://github.com/iaintshine/ruby-spanmanager). After that use it as a usual Ruby logger.

```ruby
require 'spanmanager'
require 'tracing-logger'

OpenTracing.global_tracer = SpanManager::Tracer.new(OpenTracing.global_tracer)
logger = Tracing::Logger.new(active_span: -> { OpenTracing.global_tracer.active_span }, level: Logger::ERROR)
logger.error("description of some exceptional event")
```

The gem comes with `Tracing::CompositeLogger`. It allows to specify multiple destination loggers, each with different level and formatter. Might be very useful in cases where you want to write all the logs to a file, and only those exceptional to a tracer.  

```ruby
tracing_logger = Tracing::Logger.new(active_span: -> { OpenTracing.global_tracer.active_span }, level: Logger::ERROR)
file_logger = Logger.new('log.txt')
composite_logger = Tracing::CompositeLogger.new(tracing_logger, file_logger)
composite_logger.error("description of some exceptional event") # => both destinations, tracing and file loggers, will be callled
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iaintshine/ruby-tracing-logger. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

