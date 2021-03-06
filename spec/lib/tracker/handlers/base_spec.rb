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

  it "calling conversion raises error" do
    expect do
      base.conversion
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

      def conversion
        default_conversion_args
      end
    end

    let(:test_handler) do
      TestHandler.new(
        api_key: "api_key", env: env, uuid_fetcher: uuid_fetcher
      )
    end

    it "returns default page args" do
      expect(test_handler.page).to eq({
        uuid:               "uuid",
        user_id:            1,
        host_name:          "localhost:3000",
        path:               "/",
        user_agent:         "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6)",
        utm_param:          ["1", "2"],
        utm_source:         ["a"],
        referrer:           nil,
        ua_device_name:     nil,
        ua_device_type:     "desktop",
        ua_full_version:    nil,
        ua_name:            nil,
        ua_os_full_version: "10.12.6",
        ua_os_name:         "Mac"
      })
    end

    it "returns default event args" do
      expect(test_handler.event).to eq({
        uuid:      "uuid",
        user_id:   1,
        host_name: "localhost:3000"
      })
    end

    it "returns default conversion args" do
      expect(test_handler.conversion).to eq(
        uuid:      "uuid",
        user_id:   1,
      )
    end
  end
end
