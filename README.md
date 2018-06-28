# Tracker

Tracker is a gem for tracking events in Rails applications. It hooks in Rack to send page events automatically. Inspired by https://github.com/railslove/rack-tracker.

## Installation

```ruby
gem 'tracker'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tracker

## Usage

* use as middleware

```ruby
# config/application.rb
config.middleware.use(Tracker::Middleware) do
  # register handlers
  handler Tracker::GoogleAnalytics, { api_key: "" }
  handler Tracker::Handlers::Ahoy, { api_key: "" }

  # TODO
  handler Tracker::Amplitude, { api_key: "" }

  # specify which background worker to use to async send events
  queuer Tracker::Background::Sidekiq

  # specify how to get UUID for user from env
  uuid do |env|
    env["UUID"]
  end
end

# in a controller
queue_tracker do |t|
  t.page "/path", {a: 1}
  t.event "event_name", {a: 2}
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/WalkerAndCoBrandsInc/tracker

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
