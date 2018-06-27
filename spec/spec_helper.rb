$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require "rspec"
require "rack/test"
require "vcr"
require "pry"

require "tracker"

# order matters here
require "sidekiq"
require "sidekiq/testing"
require "tracker/background/sidekiq.rb"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr_cassettes"
end
