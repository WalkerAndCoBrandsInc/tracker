require "staccato"
require_relative "./base"

class Tracker::Handlers::GoogleAnalytics < Tracker::Handlers::Base
  attr_reader :env, :client

  # Accepts:
  #   api_key      - String
  #   env          - Hash
  #   uuid_fetcher - Proc, should return String/int UUID of user.
  def initialize(api_key:, env:, uuid_fetcher:)
    @env    = env
    @client = Staccato.tracker(api_key, uuid_fetcher.call(env), ssl: true)
  end

  # Accepts:
  #   path   - String
  #   params - Hash, optional
  def page(path, params = {})
    client.pageview(default_params.merge(params.merge(path: path)))
  end

  # Accepts:
  #   name   - String
  #   params - Hash, optional
  #     category - String
  #     action   - String
  #     label    - String
  #     value    - String
  def event(name, params = {})
    client.event(default_params.merge(params.merge(action: name)))
  end

  private

  # default_params are sent with `page` and `event` api calls.
  def default_params
    {
      aip:        true, # anonymize ip
      hostname:   env["HTTP_HOST"],
      path:       env["PATH_INFO"],
      user_agent: env["HTTP_USER_AGENT"]
    }
  end
end
