# Tracker


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
config.middleware.use(Tracker) do
  handlers << Tracker::GoogleAnalytics.new(api_key: "")
  handlers << Tracker::Amplitude.new(api_key: "")
  handlers << Tracker::Ahoy.new(api_key: "")

  queuer << Tracker::SidekiqWorker
end

class Tracker::SidekiqWorker
  def perform(*params)
  end
end

Tracker.queue do |t|
  t.page "/path", params
  t.event "event_name", params
  t.event Tracker::ADD_PRODUCT_NAME, params
  t.event Tracker::TRANSATION, params
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/WalkerAndCoBrandsInc/ruby

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
