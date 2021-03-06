require "spec_helper"

describe "Amplitude" do
  let(:queuer) do
    Tracker::Handlers::Amplitude::Queuer.new(
      api_key: "api_key",
      env: env,
      uuid_fetcher: uuid_fetcher,
      session_fetcher: session_fetcher
    )
  end

  let(:updated_env) do
    env_with_request_params
  end

  let(:queue_with_request_params) do
    Tracker::Handlers::Amplitude::Queuer.new(
      api_key: "api_key", env: updated_env, uuid_fetcher: uuid_fetcher
    )
  end

  let(:api_key) { "api_key" }

  let(:session_fetcher) { -> proc {} }

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
            event_properties: hash_including(a: 1, path: "/")
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
            event_properties: hash_including(a: 1)
          )
        }
      })
    end

    it "builds event with given time arg" do
      expect(queuer.event(name: "event name", event_args: {time: 1})).to include({
        track: {
          api_key: "api_key",
          event_args: hash_including(
            event_type: "event name",
            event_properties: Hash,
            time: 1
          )
        }
      })
    end

    it "builds event with given insert_id arg" do
      expect(queuer.event(name: "event name", event_args: {insert_id: 1})).to include({
        track: {
          api_key: "api_key",
          event_args: hash_including(
            event_type: "event name",
            event_properties: Hash,
            insert_id: 1
          )
        }
      })
    end

    it 'builds conversion with given and default args' do
      args = {
        revenue: 10,
        shipping: 5,
        tax: 1,
        currency: 'USD'
      }
      expect(queuer.conversion(
        id: 1,
        event_args: args
      )).to include({
        track: {
          api_key: 'api_key',
          event_args: a_hash_including(
            event_type: 'revenue',
            event_properties: a_hash_including(
              revenue: 10
            )
          )
        }
      })
    end

    context "with request params" do
      it "removes the user password in the params before tracking" do
        expect(queue_with_request_params.page(path: "/sessions")).to include({
          track: {
            api_key:    "api_key",
            event_args: hash_including(
              device_id: "uuid",
              insert_id: String,
              time:      String,
              event_type: "Visited page",
              event_properties: hash_including(path: "/sessions", user: {email: "overwow@wilding.com"})
            )
           }
        })
      end
    end

    context 'with session' do
      let(:session_fetcher) { -> proc { 1 } }

      it "builds args with session_id" do
        expect(queuer.page(path: "/")).to include({
          track: {
            api_key:    "api_key",
            event_args: hash_including(
              session_id: 1
            )
          }
        })
      end
    end
  end

  describe "Client" do
    subject { Tracker::Handlers::Amplitude::Client }

    it "sets client api key" do
      expect(HTTParty).to receive(:post)
      subject.track(queuer.page(path: "/", page_args: {a: 1})[:track])
    end

    it "transforms registration event" do
      expect(HTTParty).to receive(:post).
        with(String, {body: hash_including(event: match(/Registered/))})

      expect(HTTParty).to receive(:post).
        with(String, {body: hash_including(event: match(/\$identify/))})

      subject.track(
        queuer.event(
          name: Tracker::REGISTRATION, event_args: {event_properties: {a: 1}}
        )[:track]
      )
    end
  end
end
