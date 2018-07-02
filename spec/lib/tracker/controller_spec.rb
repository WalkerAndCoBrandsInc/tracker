require "spec_helper"

RSpec.describe Tracker::Controller do
  def app
    Rack::Builder.new do
      use UUIDSetter
      use Tracker::Middleware do
        handler(
          queue_class:  Tracker::GoogleAnalytics::Queuer,
          client_class: Tracker::GoogleAnalytics::Client,
          opts:         { api_key: "api_key" }
        )

        queuer Tracker::Background::Sidekiq

        uuid do |env|
          env[UUIDSetter::KEY]
        end
      end

      run MetalController.action(:index)
    end
  end

  describe "#tracker" do
    context "controller" do
      subject { app }

      it "queues given block" do
        expect(Tracker::Background::Sidekiq).to receive(:queue).with(
          "Tracker::Handlers::GoogleAnalytics::Client",
          {
            page: {
              path:"/path",
              client_args: {uuid:"1", api_key:"api_key"},
              page_args: {
                aip:        true,
                path:       "/",
                hostname:   "example.org",
                user_agent: nil,
                a:          1
              }
            }
          }
        )

        get "/"
      end
    end
  end
end
