require "spec_helper"

describe "Ahoy" do
  let(:queuer) do
    Tracker::Handlers::Ahoy::Queuer.new(env: env, uuid_fetcher: uuid_fetcher)
  end

  describe "Queuer" do
    it "builds pageview with given args" do
      expect(queuer.page(path: "/", page_args: {a: 1})).to include({
        page: { path: "/", page_args: Hash }
      })
    end

    it "builds event with given and default args" do
      expect(queuer.event(name: "event name", event_args: {a: 1})).to include({
        event: { name: "event name", event_args: Hash }
      })
    end

    it "builds conversion with given and default args" do
      expect(queuer.conversion(id: 1, event_args: {a: 1})).to include({
        event: { name: 'conversion', event_args: Hash }
      })
    end
  end

  describe "Client" do
    subject { Tracker::Handlers::Ahoy::Client }

    it "tracks pageview with given and default args" do
      page_args = {
        user_agent: env["HTTP_USER_AGENT"],
        host_name:  env["HTTP_HOST"],
      }

      expect_any_instance_of(Ahoy::Tracker).to receive(:track).
        with("Visited page", hash_including(page_args))

      subject.page(queuer.page(path: "/", page_args: {a: 1})[:page])
    end
  end
end
