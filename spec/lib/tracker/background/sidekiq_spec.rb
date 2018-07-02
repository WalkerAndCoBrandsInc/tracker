require "spec_helper"

# order matters here
require "sidekiq"
require "tracker/background/sidekiq.rb"

module Tracker::Background
  describe Sidekiq do
    let(:queuer) do
      Tracker::Handlers::GoogleAnalytics::Queuer.new(
        api_key: "api_key", env: env, uuid_fetcher: proc { "1" }
      )
    end

    subject { Tracker::Background::Sidekiq.new }

    it "calls client with args" do
      expect(Tracker::Handlers::GoogleAnalytics::Client).to receive(:page).with({
        path:        "/",
        client_args: {uuid:"1", api_key:"api_key"},
        page_args:   {
          aip:        true,
          path:       "/",
          hostname:   "localhost:3000",
          user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6)",
          user_id:    1,
          uuid:       "1"
        }}
      )

      subject.perform(
        "Tracker::Handlers::GoogleAnalytics::Client", queuer.page(path: "/")
      )
    end
  end
end
