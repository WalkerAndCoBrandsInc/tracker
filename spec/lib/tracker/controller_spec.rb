require "spec_helper"

RSpec.describe Tracker::Controller do
  describe "#tracker" do
    subject { app }

    context do
      it "does not track non text/html pages" do
        expect_any_instance_of(Tracker::PageTrack).
          to_not receive(:track)

        header "ACCEPT", "text/css,*/*;q=0."
        get "style.css"
      end

      it "tracks text/html pages" do
        expect_any_instance_of(Tracker::PageTrack).to receive(:track)

        header "ACCEPT", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"
        get "/"
      end
    end

    context "controller" do
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
