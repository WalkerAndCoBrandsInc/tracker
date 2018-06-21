require "spec_helper"

describe Tracker do
  def app
    Rack::Builder.new do
      use Tracker::Middleware do
        handlers << "Tracker1"
        handlers << "Tracker2"

        queuer "QueurClassName"
        uuid do |env|
          env["SOMETHING_HEADER"]
        end
      end

      run lambda {|env|
        r = [].tap do |resp|
          t = env["tracker"]

          resp << "Handlers is set" if !t.handlers.empty?
          resp << "Queuer is set" if t.queuer
          resp << "UUID is set" if t.uuid
        end

        [200, {}, r ]
      }
    end
  end

  subject { app }

  it "stores list of handlers" do
    get "/"
    expect(last_response.body).to include("Handlers is set")
  end

  it "stores queuer" do
    get "/"
    expect(last_response.body).to include("Queuer is set")
  end

  it "stores UUID env fetcher block" do
    get "/"
    expect(last_response.body).to include("UUID is set")
  end
end
