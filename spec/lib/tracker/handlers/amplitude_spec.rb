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
          name:       "Visited page",
          api_key:    "api_key",
          event_args: hash_including(
            device_id: "uuid",
            path:      "/",
            insert_id: String,
            time:      String,
            event_properties: {a: 1}
          )
        }
      })
    end

    it "builds event with given and default args" do
      expect(queuer.event(name: "event name", event_args: {a: 1})).to include({
        track: {
          name:    "event name",
          api_key: "api_key",
          event_args: hash_including(
            event_properties: {a: 1}
          )
        }
      })
    end
  end

  describe "Client" do
    subject { Tracker::Handlers::Amplitude::Client }

    it "sets client api key" do
      expect(AmplitudeAPI).to receive(:api_key=).with("api_key")

      subject.track(queuer.page(path: "/", page_args: {a: 1})[:track])
    end
  end
end
