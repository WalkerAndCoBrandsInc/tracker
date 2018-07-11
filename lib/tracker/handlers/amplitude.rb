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
          event_args: build_event_args(Tracker::VISITED_PAGE, page_args.merge(path: path))
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
          event_args: build_event_args(name, event_args)
        }
      }
    end

    private

    def build_event_args(name, args)
      {
        user_id:          args[:user_id],
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
      URL = "https://api.amplitude.com/httpapi".freeze

      def track(api_key:, event_args: {})
        HTTParty.post(URL, {body: {api_key: api_key, event: JSON.dump(event_args)}})
      end
    end
  end
end

module Tracker; Amplitude = Handlers::Amplitude; end
