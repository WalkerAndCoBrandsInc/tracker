require_relative "./base"
require "httparty"

module Tracker::Handlers::Amplitude
  class Queuer < Tracker::Handlers::Base

    # Accepts:
    #   path      - String
    #   page_args - Hash, optional
    #
    # Returns:
    #   Hash
    def page(path:, page_args: {})
      {
        track: {
          api_key:    api_key,
          event_args: build_event_args(
            Tracker::VISITED_PAGE,
            default_page_args.merge(page_args.merge(path: path))
          )
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
        track: {
          api_key:    api_key,
          event_args: build_event_args(name, default_event_args.merge(event_args))
        }
      }
    end

    private

    def build_event_args(name, args)
      {
        user_id:          args[:user_id] || user_id_from_session,
        device_id:        uuid,
        event_type:       name,
        event_properties: args,
        insert_id:        SecureRandom.base64,
        time:             DateTime.now.strftime('%Q')
      }
    end
  end

  class Client
    class << self
      URL      = "https://api.amplitude.com/httpapi".freeze
      IDENTIFY = "$identify".freeze

      # Accepts:
      #   api_key    - String
      #   event_args - Hash
      def track(api_key:, event_args: {})
        case event_args[:event_type]
        when Tracker::REGISTRATION
          # post regular event first
          post(api_key, event_args)

          # then post $identify event
          event_args[:event_type] = IDENTIFY
          event_args[:user_properties] = {"$set" => event_args[:event_properties]}
          event_args = event_args.except(:event_properties)
        end

        post(api_key, event_args)
      end

      private

      def post(api_key, args)
        HTTParty.post(URL, {body: {api_key: api_key, event: JSON.dump(args)}})
      end
    end
  end
end

module Tracker; Amplitude = Handlers::Amplitude; end
