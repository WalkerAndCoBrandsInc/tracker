require "spec_helper"

describe "Ahoy" do
  let(:queuer) do
    Tracker::Handlers::Ahoy::Queuer.new(env: {}, uuid_fetcher: proc { "1" })
  end

  describe "Queuer" do
    it "builds pageview with given args" do
      expect(queuer.page(path: "/", page_args: {a: 1})).to eq({
        page: { path: "/", page_args: { a: 1 }}
      })
    end

    it "builds event with given and default args" do
      expect(queuer.event(name: "event name", event_args: { a: 1 })).to eq({
        event: { name: "event name", event_args: { a: 1}}
      })
    end
  end

  describe "Client" do
    subject { Tracker::Handlers::Ahoy::Client }

    it "tracks pageview with given and default args" do
      expect_any_instance_of(Ahoy::Tracker).to receive(:track).
        with("Visited page", {:a=>1, :path=>"/"})

      subject.page(queuer.page(path: "/", page_args: {a: 1})[:page])
    end
  end
end
