require "staccato"
require_relative "./base"

class Tracker::Handlers::GoogleAnalytics
  class Queuer < Tracker::Handlers::Base

    # Accepts:
    #   path      - String
    #   page_args - Hash, optional
    # Returns:
    #   Hash
    def page(path, page_args = {})
      {
        page: {
          path:        path,
          client_args: client_args,
          page_args:   default_args.merge(page_args)
        }
      }
    end

    # Accepts:
    #   name       - String
    #   event_args - Hash, optional
    # Returns:
    #   Hash
    def event(name, event_args = {})
      {
        event: {
          name:        name,
          client_args: client_args,
          page_args:   default_args.merge(event_args)
        }
      }
    end

    private

    # default_args are sent with all `page` and `event` calls.
    #
    # Returns:
    #   Hash
    def default_args
      {
        aip:        true, # anonymize ip
        path:       env["PATH_INFO"],
        hostname:   env["HTTP_HOST"],
        user_agent: env["HTTP_USER_AGENT"]
      }
    end

    # client_args are client specific, ie `Staccato.tracker` arguments; this
    # will not be sent to Google Analytics.
    #
    # Returns:
    #   Hash
    def client_args
      {uuid: uuid, api_key: api_key }
    end
  end

  class Client
    class << self
      # Accepts:
      #   path        - String
      #   client_args - Hash
      #   page_args   - Hash, optional
      def page(path:, client_args:, page_args:{})
        client(client_args).pageview(page_args.merge(path: path))
      end

      # Accepts:
      #   name        - String
      #   client_args - Hash
      #   event_args  - Hash, optional
      #     category - String
      #     action   - String
      #     label    - String
      #     value    - String
      def event(name:, client_args:, page_args:{})
        client(client_args).event(page_args.merge(action: name))
      end

      private

      # Accepts:
      #   client_args - Hash
      #     api_key - String
      #     uuid    - String
      def client(client_args)
        Staccato.tracker(client_args[:api_key], client_args[:uuid], ssl: true)
      end
    end
  end
end
