require "spec_helper"

RSpec.describe Tracker::Controller do
  describe "#tracker" do
    context "controller" do
      subject { app }

      let(:client_args) { {uuid:"1", api_key:"api_key"} }
      let(:event_args) {
        {
          aip:        true,
          path:       "/",
          hostname:   "example.org",
          user_agent: nil,
          uuid:       "1",
          user_id:    1,
          a:          1
        }
      }

      it "queues block" do
        allow(Tracker::GoogleAnalytics::Client).to receive(:event)
        expect(Tracker::Background::Sidekiq).to receive(:queue).with(
         "Tracker::Handlers::GoogleAnalytics::Client", {
           event: {
             name:        "event",
             client_args:  client_args,
             event_args:   event_args
           }
         }
        ).and_call_original

        get "/"

        Tracker::Background::Sidekiq.drain
      end

      it "calls handler event" do
        expect(Tracker::GoogleAnalytics::Client).to receive(:event).with({
          name:        "event",
          client_args: client_args,
          event_args:  event_args
        })

        get "/"

        Tracker::Background::Sidekiq.drain
      end
    end
  end
end
