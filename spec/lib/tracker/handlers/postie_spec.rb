require "spec_helper"

describe "Postie" do
  let(:queuer) do
    Tracker::Handlers::Postie::Queuer.new(
      env: env,
      uuid_fetcher: uuid_fetcher,
      endpoint: 'endpoint',
      app_id: 'app_id'
    )
  end

  describe "Queuer" do
    it "builds pageview with given args" do
      expect(queuer.page(path: "/", page_args: {a: 1})).to include({
        page: { path: "/", client_args: Hash }
      })
    end

    it "builds conversion with given and default args" do
      expect(queuer.conversion(id: 1, event_args: {a: 1})).to include({
        conversion: { id: 1, client_args: Hash, event_args: Hash }
      })
    end
  end

  describe "Client" do
    subject { Tracker::Handlers::Postie::Client }

    it "tracks pageview with given and default args" do
      expect_any_instance_of(SnowplowTracker::Tracker).to receive(:track_page_view).
        with("/")

      subject.page(queuer.page(path: "/", page_args: {a: 1})[:page])
    end

    it "tracks conversion with given and default args" do
      expect_any_instance_of(SnowplowTracker::Tracker).to receive(:track_ecommerce_transaction).
        with(
          a_hash_including("order_id" => 1),
          [a_hash_including("sku" => 'sku', "price" => 10, "quantity" => 1)],
          [an_instance_of(SnowplowTracker::SelfDescribingJson)]
        )

      subject.conversion(
        queuer.conversion(
          id: 1,
          event_args: {
            items: [{sku: 'sku', price: 10, quantity: 1}],
            customer: {}
          }
        )[:conversion]
      )
    end
  end
end
