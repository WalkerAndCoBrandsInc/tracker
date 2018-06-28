require_relative "./base"

module Tracker::Handlers::Ahoy
  class Queuer < Tracker::Handlers::Base
    def page(path, page_args = {})
      { page: { path: path, page_args: page_args } }
    end

    def event(name, event_args = {})
      { event: { name: name, event_args: event_args } }
    end
  end

  class Client
    class << self
      VISITED_PAGE = "Visited page".freeze

      def page(path:, page_args: {})
        # TODO: use native page call
        client.track(VISITED_PAGE, page_args.merge(path: path))
      end

      def event(name:, event_args: {})
        client.track(name, event_args)
      end

      private

      def client
        @client ||= Ahoy::Tracker.new
      end
    end
  end
end
