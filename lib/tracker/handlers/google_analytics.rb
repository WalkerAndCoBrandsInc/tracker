require "staccato"
require_relative "./base"

module Tracker::Handlers::GoogleAnalytics
  class Queuer < Tracker::Handlers::Base

    # Accepts:
    #   path      - String
    #   page_args - Hash, optional
    #
    # Returns:
    #   Hash
    def page(path:, page_args: {})
      {
        page: {
          path:        path,
          client_args: client_args,
          page_args:   default_page_args.merge(page_args)
        }
      }
    end

    # Accepts:
    #   name       - String
    #   event_args - Hash, optional
    #
    # Returns:
    #   Hash
    def event(name:, event_args: {})
      {
        event: {
          name:        name,
          client_args: client_args,
          event_args:  default_event_args.merge(event_args)
        }
      }
    end

    # Accepts:
    #   id         - String
    #   event_args - Hash, optional
    #
    # Returns:
    #   Hash
    def conversion(id:, event_args: {})
      {
        conversion: {
          id: id,
          client_args: client_args,
          event_args:  default_event_args.merge(event_args)
        }
      }
    end

    private

    # default_args are sent with all `page` and `event` calls.
    #
    # Returns:
    #   Hash
    def default_page_args
      super.except(:host_name).merge({
        aip:        true, # anonymize ip
        hostname:   env["HTTP_HOST"]
      })
    end

    def default_event_args
      super.except(:host_name).merge({
        aip:        true, # anonymize ip
        hostname:   env["HTTP_HOST"]
      })
    end

    # client_args are client specific, ie `Staccato.tracker` arguments; this
    # will not be sent to Google Analytics.
    #
    # Returns:
    #   Hash
    def client_args
      { uuid: uuid, api_key: api_key }
    end
  end

  class Client
    class << self

      # Accepts:
      #   path        - String
      #   client_args - Hash
      #   page_args   - Hash, optional
      def page(path:, client_args:, page_args: {})
        client(client_args).pageview(page_args.merge(
          path: path,
          campaign_name:    page_args[:utm_name],
          campaign_source:  page_args[:utm_source],
          campaign_medium:  page_args[:utm_medium],
          campaign_keyword: page_args[:utm_keyword],
          campaign_content: page_args[:utm_content],
          campaign_id:      page_args[:utm_id]
        ))
      end

      # Accepts:
      #   name        - String
      #   client_args - Hash
      #   event_args  - Hash, optional
      #     category - String
      #     action   - String
      #     label    - String
      #     value    - String
      def event(name:, client_args:, event_args: {})
        client(client_args).event(event_args.merge(action: name))
      end

      # Accepts:
      #   name        - String
      #   client_args - Hash
      #   event_args  - Hash, optional
      #     category - String
      #     action   - String
      #     label    - String
      #     value    - String
      def conversion(id:, client_args:, event_args: {})
        client(client_args).transaction(event_args.merge(transaction_id: id))
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

module Tracker; GoogleAnalytics = Handlers::GoogleAnalytics; end
