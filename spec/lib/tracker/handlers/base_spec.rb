require "spec_helper"

describe "Base" do
  let(:base) do
    Tracker::Handlers::Base.new(
      api_key: "api_key", env: env, uuid_fetcher: uuid_fetcher
    )
  end

  it "calling page raises error" do
    expect do
      base.page
    end.to raise_error(Tracker::Handlers::Base::NotImplemented)
  end

  it "calling event raises error" do
    expect do
      base.event
    end.to raise_error(Tracker::Handlers::Base::NotImplemented)
  end

  describe "TestHandler" do
    class TestHandler < Tracker::Handlers::Base
      def page
        default_page_args
      end

      def event
        default_event_args
      end
    end

  let(:test_handler) do
    TestHandler.new(
      api_key: "api_key", env: env, uuid_fetcher: uuid_fetcher
    )
  end

    it "returns default page args" do
      expect(test_handler.page).to eq({
        uuid:       "uuid",
        user_id:    1,
        host_name:  "localhost:3000",
        path:       "/",
        user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6)",
        utm_param:  "2",
        utm_source: "a"
      })
    end

    it "returns default event args" do
      expect(test_handler.event).to eq({
        uuid:      "uuid",
        user_id:   1,
        host_name: "localhost:3000"
      })
    end
  end
end
