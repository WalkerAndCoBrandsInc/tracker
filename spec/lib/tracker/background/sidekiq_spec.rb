require "spec_helper"

# order matters here
require "sidekiq"
require "tracker/background/sidekiq.rb"

module Tracker::Background
  describe Sidekiq do
    let(:queuer) do
      Tracker::Handlers::GoogleAnalytics::Queuer.new(
        api_key: "api_key", env: env, uuid_fetcher: uuid_fetcher
      )
    end

    subject { Tracker::Background::Sidekiq.new }

    it "calls client with args" do
      expect(Tracker::Handlers::GoogleAnalytics::Client).to receive(:page).with({
        path:        "/",
        client_args: Hash,
        page_args:   Hash
      })

      subject.perform(
        "Tracker::Handlers::GoogleAnalytics::Client", queuer.page(path: "/")
      )
    end
  end
end
