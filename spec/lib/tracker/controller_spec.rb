require "spec_helper"

RSpec.describe Tracker::Controller do
  describe "#tracker" do
    context "controller" do
      subject { app }

      before do
        # this calls 'page', so below matchers don't work
        allow_any_instance_of(Tracker::Middleware).to receive(:track_page)
      end

      it "queues block" do
        allow(Tracker::GoogleAnalytics::Client).to receive(:event)
        expect(Tracker::Background::Sidekiq).to receive(:queue).with(
         "Tracker::Handlers::GoogleAnalytics::Client",
         {event: {name: "event", client_args: Hash, event_args: Hash }}
        ).and_call_original

        get "/"

        Tracker::Background::Sidekiq.drain
      end

      it "calls handler event" do
        expect(Tracker::GoogleAnalytics::Client).to receive(:event).with(
          hash_including(name:"event", client_args: Hash, event_args: Hash)
        )

        get "/"

        Tracker::Background::Sidekiq.drain
      end
    end
  end
end
