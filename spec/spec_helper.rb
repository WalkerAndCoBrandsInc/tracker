$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require "rspec"
require "rack/test"
require "vcr"
require "pry"

require "ahoy"
require "staccato"

require "tracker"

# order matters here
require "sidekiq"
require "sidekiq/testing"
require "tracker/background/sidekiq"
require "tracker/handlers/ahoy"
require "tracker/handlers/google_analytics"
require "tracker/handlers/amplitude"

# Required to make Ahoy work in non Rails env
class Ahoy::Store < Ahoy::Stores::LogStore
end

def Time.zone; self; end unless Time.respond_to?(:zone)

module Rails
  unless Rails.respond_to?(:root)
    def Rails.root
      Pathname.new(Dir.tmpdir).tap do |tmpdir|
        return tmpdir if Dir.exists?(tmpdir)
        Dir.mkdir(File.join(tmpdir, "log"), 0700)
      end
    end
  end
end
# Required to make Ahoy work in non Rails env

require "tracker/handlers/ahoy"

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include EnvHelpers
  config.include App
end
