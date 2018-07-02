require "spec_helper"

describe "GoogleAnalytics" do
  let(:queuer) do
    Tracker::Handlers::GoogleAnalytics::Queuer.new(
      api_key: "api_key", env: env, uuid_fetcher: proc { "1" }
    )
  end

  describe "Queuer" do
    it "builds pageview with given and default args" do
      expect(queuer.page(path: "/", page_args: {a: 1})).to eq({
        page: {
          path:"/",
          client_args:{uuid:"1", api_key:"api_key"},
          page_args:{
            aip:        true,
            path:       "/",
            user_agent: env["HTTP_USER_AGENT"],
            hostname:   env["HTTP_HOST"],
            a:          1,
            uuid:       "1",
            user_id:    1
          }
        }
      })
    end

    it "builds event with given and default args" do
      expect(queuer.event(
        name: "event name",
        event_args: {category: "category", label: "label", value: 1})
      ).to eq({
        event: {
          name: "event name",
          client_args: {uuid:"1", api_key:"api_key"},
          event_args: {
            aip:true,
            path:"/",
            hostname: env["HTTP_HOST"],
            user_agent: env["HTTP_USER_AGENT"],
            category:"category",
            label:"label", value:1,
            uuid:       "1",
            user_id:    1
          }
        }
      })
    end
  end

  describe "Client" do
    subject { Tracker::Handlers::GoogleAnalytics::Client }

    it "initializes client with user uuid" do
      expect(Staccato).to receive(:tracker).with("api_key", "1", ssl:true).
        and_return(double(pageview: nil))

      subject.page(queuer.page(path: "/", page_args: {a: 1})[:page])
    end

    it "tracks pageview with given and default args" do
      expect_any_instance_of(Staccato::Tracker).to receive(:pageview).with({
        path:       "/",
        a:          1,
        aip:        true,
        hostname:   env["HTTP_HOST"],
        path:       env["PATH_INFO"],
        user_agent: env["HTTP_USER_AGENT"],
        uuid:       "1",
        user_id:    1
      })

      subject.page(queuer.page(path: "/", page_args: {a: 1})[:page])
    end

    it "tracks event with given and default args" do
      expect_any_instance_of(Staccato::Tracker).to receive(:event).with({
        aip:        true,
        hostname:   env["HTTP_HOST"],
        path:       env["PATH_INFO"],
        user_agent: env["HTTP_USER_AGENT"],
        category:   "category",
        label:      "label",
        action:     "event name",
        value:      1,
        uuid:       "1",
        user_id:    1
      })

      subject.event(
        queuer.event(
          name: "event name",
          event_args: {category: "category", label: "label", value: 1}
        )[:event]
      )
    end
  end
end
