require "spec_helper"

describe "GoogleAnalytics" do
  let(:queuer) do
    Tracker::Handlers::GoogleAnalytics::Queuer.new(
      api_key: "api_key", env: env, uuid_fetcher: uuid_fetcher
    )
  end

  let(:client_args) { {uuid: "uuid", api_key: "api_key"} }

  describe "Queuer" do
    it "builds pageview with given and default args" do
      expect(queuer.page(path: "/", page_args: {a: 1})).to include({
        page: {
          path:        "/",
          client_args: client_args,
          page_args:   hash_including(
            aip:       true,
            hostname:  env["HTTP_HOST"],
            path:      "/",
            a:         1
          )
        }
      })
    end

    it "builds event with given and default args" do
      expect(queuer.event(
        name: "event name",
        event_args: {category: "category", label: "label", value: 1})
      ).to include({
        event: {
          name:        "event name",
          client_args: client_args,
          event_args:  hash_including(
            aip:       true,
            hostname:  env["HTTP_HOST"],
            category:  "category",
            label:     "label",
            value:     1
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
        conversion: {
          id: 1,
          client_args: client_args,
          event_args: a_hash_including(args)
        }
      })
    end
  end

  describe "Client" do
    subject { Tracker::Handlers::GoogleAnalytics::Client }

    it "initializes client with user uuid" do
      expect(Staccato).to receive(:tracker).with("api_key", "uuid", ssl:true).
        and_return(double(pageview: nil))

      subject.page(queuer.page(path: "/", page_args: {a: 1})[:page])
    end

    it "tracks pageview with given and default args" do
      expect_any_instance_of(Staccato::Tracker).to receive(:pageview).
        with(hash_including(
          hostname:   env["HTTP_HOST"],
          user_agent: env["HTTP_USER_AGENT"]
        )
      )

      subject.page(queuer.page(path: "/", page_args: {a: 1})[:page])
    end

    it "tracks event with given and default args" do
      expect_any_instance_of(Staccato::Tracker).to receive(:event).with({
        aip:        true,
        hostname:   env["HTTP_HOST"],
        category:   "category",
        label:      "label",
        action:     "event name",
        value:      1,
        uuid:       "uuid",
        user_id:    1,
      })

      subject.event(
        queuer.event(
          name: "event name",
          event_args: {category: "category", label: "label", value: 1}
        )[:event]
      )
    end

    it 'tracks a conversion with given params' do
      expect_any_instance_of(Staccato::Tracker).to receive(:transaction).with(
        a_hash_including(
          transaction_id: 1
        )
      )

      subject.conversion(
        queuer.conversion(
          id: 1,
          event_args: {}
        )[:conversion]
      )
    end
  end
end
