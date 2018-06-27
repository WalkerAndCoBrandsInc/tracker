require "active_support/inflections"

class Tracker::Background::Sidekiq < Tracker::Background::Base
  include ::Sidekiq::Worker

  class << self
    alias_method :queue, :perform_async
  end

  # Accepts:
  #   klass_str       - String, one of Tracker::Handlers
  #   tracker_actions - [ ]
  def perform(klass_str, tracker_actions)
    klass = klass_str.constantize
    tracker_actions.each do |method, args|
      args.each { |a| klass.send(method, *a) }
    end
  end
end
