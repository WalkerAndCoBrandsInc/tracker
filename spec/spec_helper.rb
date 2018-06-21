$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require "rspec"
require "rack/test"
require "tracker"
require "pry"

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
