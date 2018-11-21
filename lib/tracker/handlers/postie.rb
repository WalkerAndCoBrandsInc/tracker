require "snowplow-tracker"
require_relative "./base"

module Tracker::Handlers::Postie
  class Queuer < Tracker::Handlers::Base
    attr_reader :endpoint, :app_id

    def initialize(endpoint: "", app_id: "", env: , uuid_fetcher: -> proc {}, uuid: nil, session_fetcher: -> proc {}, session: nil)
      @app_id   = app_id
      @endpoint = endpoint
      @env     = env
      @uuid    = uuid || uuid_fetcher.call(env)
      @session = session || session_fetcher.call(env)
      env['rack.input'].rewind if env.present?
    end

    def page(path:, page_args: {})
      {
        page: {
          path: path,
          client_args: client_args,
        },
      }
    end

    # TODO: Not implemented
    def event(name:, event_args: {})
      {}
    end

    def conversion(id:, event_args: {})
      {
        conversion: {
          id: id,
          client_args: client_args,
          event_args: event_args
        }
      }
    end

    private

    def client_args
      { endpoint: endpoint, app_id: app_id }
    end
  end

  class Client
    class << self

      def page(path:, client_args:)
        client(client_args).track_page_view(
          path
        )
      end

      # TODO: Not implemented
      def event(name:, client_args:, event_args: {})
      end

      def conversion(id:, client_args:, event_args: {})
        client(client_args).track_ecommerce_transaction(
          {
            "order_id" => id,
            "total_value" => event_args[:revenue],
            "tax_value" => event_args[:tax],
            "shipping" => event_args[:shipping],
            "currency" => event_args[:currency]
          },
          event_args[:items].map do |item|
            {
              "sku" => item[:sku],
              "price" => item[:price],
              "quantity" => item[:quantity]
            }
          end,
          [
            SnowplowTracker::SelfDescribingJson.new(
              'iglu:com.getletterpress/address/jsonschema/1-0-0',
              {
                'name' => event_args[:customer][:name],
                'street' => event_args[:customer][:street],
                'street_2' => event_args[:customer][:street_2] || '',
                'zip' => event_args[:customer][:zip],
                'city' => event_args[:customer][:city],
                'state' => event_args[:customer][:state],
                'country' => event_args[:customer][:country],
                'email' => event_args[:customer][:email]
              }
            )
          ]
        )
      end

      private

      def client(client_args)
        emitter = SnowplowTracker::Emitter.new(client_args[:endpoint])
        SnowplowTracker::Tracker.new(
          emitter,
          SnowplowTracker::Subject.new,
          'lp',
          client_args[:app_id],
          false
        )
      end
    end
  end
end

module Tracker; Postie = Handlers::Postie; end
