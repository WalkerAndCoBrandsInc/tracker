require "spec_helper"

RSpec.describe Tracker::Controller do
  describe "queue_tracker" do
    subject { app }

    context "middleware" do
      it "sets global instance" do
        header "ACCEPT", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"
        get "/"

        expect(Tracker.middle_instance).to be_a(Tracker::Middleware)
      end
    end

    context "PageTrack" do
      it "tracks text/html pages" do
        expect_any_instance_of(Tracker::PageTrack).to receive(:track)

        header "ACCEPT", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"
        get "/"
      end

      it "does not track non text/html pages" do
        expect_any_instance_of(Tracker::PageTrack).
          to_not receive(:track)

        header "ACCEPT", "text/css,*/*;q=0."
        get "/"
      end

      it "does not track bots" do
        expect_any_instance_of(Tracker::PageTrack).
          to_not receive(:track)

        header "ACCEPT", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"
        header "USER_AGENT", "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
        get "/"
      end

      it "does not track non existent routes" do
        expect_any_instance_of(Tracker::PageTrack).
          to_not receive(:track)

        header "ACCEPT", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"
        get "/404"
      end

      context 'when has ignored paths' do
        def app
          Rack::Builder.new do
            use UUIDSetter
            use Tracker::Middleware do
              uuid do |env|
                env[UUIDSetter::KEY]
              end

              ignore_paths ['/ignored', '/ignored/*/paths']
            end

            run MetalController.action(:index)
          end
        end

        it 'does not track' do
          expect_any_instance_of(Tracker::PageTrack).
            to_not receive(:track)
          header "ACCEPT", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"
          get "/ignored"
        end

        it 'supports matchers' do
          expect_any_instance_of(Tracker::PageTrack).
            to_not receive(:track)
          header "ACCEPT", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"
          get "/ignored/other/paths"
        end

        it 'tracks if not ignored' do
          expect_any_instance_of(Tracker::PageTrack).
            to receive(:track)
          header "ACCEPT", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"
          get "/ignored/this-will-track/successfuly"
        end

        it 'tracks home' do
          expect_any_instance_of(Tracker::PageTrack).
            to receive(:track)
          header "ACCEPT", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"
          get "/"
        end
      end
    end

    context "controller" do
      before do
        # this calls 'page', so below matchers don't work
        allow_any_instance_of(Tracker::Middleware).to receive(:track_page)
      end

      it "queues block" do
        allow(Tracker::GoogleAnalytics::Client).to receive(:event)
        expect(Tracker::Background::Sidekiq).to receive(:q)

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
