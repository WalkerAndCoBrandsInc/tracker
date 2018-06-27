require_relative "tracker/version"

require_relative "tracker/middleware"
require_relative "tracker/controller"
require_relative "tracker/handlers"
require_relative "tracker/background"

module Tracker
  GoogleAnalytics = Handlers::GoogleAnalytics::Queuer

  class NotImplemented < StandardError; end
end
