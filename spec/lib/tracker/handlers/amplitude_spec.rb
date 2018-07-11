require "spec_helper"

describe "Amplitude" do
  let(:queuer) do
    Tracker::Handlers::Amplitude::Queuer.new(
      api_key: "api_key", env: env, uuid_fetcher: uuid_fetcher
    )
  end

  let(:api_key) { "api_key" }

  describe "Queuer" do
    it "builds pageview with given and default args" do
      expect(queuer.page(path: "/", page_args: {a: 1})).to include({
        track: {
          api_key:    "api_key",
          event_args: hash_including(
            device_id: "uuid",
            insert_id: String,
            time:      String,
            event_type: "Visited page",
            event_properties: {a: 1, path: "/"}
          )
        }
      })
    end

    it "builds event with given and default args" do
      expect(queuer.event(name: "event name", event_args: {a: 1})).to include({
        track: {
          api_key: "api_key",
          event_args: hash_including(
            event_type: "event name",
            event_properties: {a: 1}
          )
        }
      })
    end
  end

  describe "Client" do
    subject { Tracker::Handlers::Amplitude::Client }

    it "sets client api key" do
      expect(HTTParty).to receive(:post)

      subject.track(queuer.page(path: "/", page_args: {a: 1})[:track])
    end
  end
end
