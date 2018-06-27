require "spec_helper"

# order matters here
require "sidekiq"
require "tracker/background/sidekiq.rb"

module Tracker::Background
  describe Sidekiq do
    subject { Tracker::Background::Sidekiq.new }

    skip do
      subject.perform("Tracker::GoogleAnalytics", {
        page: [{ path: "/path", params: {}}]
      })
    end
  end
end
