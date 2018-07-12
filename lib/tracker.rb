require_relative "tracker/version"

require_relative "tracker/middleware"
require_relative "tracker/controller"
require_relative "tracker/handlers"
require_relative "tracker/background"
require_relative "tracker/railtie" if defined?(Rails)

module Tracker
  VISITED_PAGE = "Visited page".freeze
  REGISTRATION = "Registered".freeze

  class NotImplemented < StandardError; end
end
