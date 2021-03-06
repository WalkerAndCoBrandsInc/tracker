require_relative "./base"

module Tracker::Handlers::Ahoy
  class Queuer < Tracker::Handlers::Base

    # Accepts:
    #   path      - String
    #   page_args - Hash, optional
    #
    # Returns:
    #   Hash
    def page(path:, page_args: {})
      { page: { path: path, page_args: default_page_args.merge(page_args) } }
    end

    # Accepts:
    #   name       - String
    #   event_args - Hash, optional
    #
    # Returns:
    #   Hash
    def event(name:, event_args: {})
      { event: { name: name, event_args: default_event_args.merge(event_args) } }
    end

    # Accepts:
    #   id         - String
    #   event_args - Hash, optional
    #
    # Returns:
    #   Hash
    def conversion(id:, event_args: {})
      { event:
        {
          name: 'conversion',
          event_args: default_conversion_args.merge(event_args).merge(
            id: id
          )
        }
      }
    end
  end

  class Client
    class << self
      # Accepts:
      #   path        - String
      #   page_args   - Hash, optional
      def page(path:, page_args: {})
        # TODO: use native page call
        client.track(Tracker::VISITED_PAGE, page_args.merge(path: path))
      end

      # Accepts:
      #   name       - String
      #   event_args - Hash, optional
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

module Tracker; Ahoy = Handlers::Ahoy; end
