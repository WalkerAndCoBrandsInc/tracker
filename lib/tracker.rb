require_relative "tracker/version"

require_relative "tracker/middleware"
require_relative "tracker/handlers"

module Tracker
  GoogleAnalytics = Handlers::GoogleAnalytics
end
