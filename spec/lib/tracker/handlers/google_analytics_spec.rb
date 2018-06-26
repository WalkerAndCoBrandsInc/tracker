require "spec_helper"

describe Tracker::Handlers::GoogleAnalytics do
  let(:env) do
    {
      "HTTP_HOST"       => "localhost:3000",
      "PATH_INFO"       => "/",
      "HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.87 Safari/537.36"
    }
  end

  subject do
    described_class.new(api_key: "api_key", env: env, uuid_fetcher: proc { "1" })
  end

  it "initializes client with user uuid" do
    expect(Staccato).to receive(:tracker).with("api_key", "1", ssl:true)
    subject
  end

  it "tracks pageview with given and default params" do
    expect_any_instance_of(Staccato::Tracker).to receive(:pageview).with({
      aip:        true,
      hostname:   env["HTTP_HOST"],
      path:       env["PATH_INFO"],
      user_agent: env["HTTP_USER_AGENT"],
    })

    subject.page("/")
  end

  it "tracks event with given and default params" do
    expect_any_instance_of(Staccato::Tracker).to receive(:event).with({
      aip:        true,
      hostname:   env["HTTP_HOST"],
      path:       env["PATH_INFO"],
      user_agent: env["HTTP_USER_AGENT"],
      category:   "category",
      label:      "label",
      action:     "event name",
      value:      1
    })

    subject.event("event name", {category: "category", label: "label", value: 1})
  end
end
