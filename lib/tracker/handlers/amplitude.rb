require_relative "./base"

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
          name:       Tracker::VISITED_PAGE,
          api_key:    api_key,
          event_args: build_event_args(page_args).merge({path: path})
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
          name:       name,
          api_key:    api_key,
          event_args: build_event_args(event_args)
        }
      }
    end

    private

    def build_event_args(args)
      {
        user_id:          args[:user_id],
        device_id:        uuid,
        event_properties: args,
        insert_id:        SecureRandom.base64,
        time:             DateTime.now.strftime('%Q')
      }
    end
  end

  class Client
    class << self
      def track(name:, api_key:, event_args: {})
        set_api_key(api_key)
        AmplitudeAPI.track(AmplitudeAPI::Event.new(event_args))
      end

      private

      # Accepts:
      #   api_key - String
      def set_api_key(api_key)
        AmplitudeAPI.api_key = api_key
      end
    end
  end
end

module Tracker; Amplitude = Handlers::Amplitude; end
