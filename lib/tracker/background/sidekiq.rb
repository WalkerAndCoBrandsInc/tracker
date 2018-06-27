require "active_support/inflections"

class Tracker::Background::Sidekiq < Tracker::Background::Base
  include ::Sidekiq::Worker

  class << self
    alias_method :queue, :perform_async
  end

  # Accepts:
  #   klass_str       - String, one of Tracker::Handlers
  #   tracker_actions - [{page: {}}, event: {}]
  def perform(klass_str, tracker_actions)
    klass = klass_str.constantize
    tracker_actions.each { |method, args| klass.send(method, args) }
  end
end
