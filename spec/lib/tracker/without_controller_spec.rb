require "spec_helper"

RSpec.describe Tracker::WithoutController do
  describe "queue_tracker" do
    before do
      subject { app }
      get "/" # sets Tracker.middle_instance
    end

    it "tracks without env" do
      expect(Tracker::Background::Sidekiq).to receive(:q)

      Tracker::WithoutController.queue_tracker({}, "uuid") do |t|
        t.page(path: "/", page_args: {a: 1})
      end
    end
  end
end
