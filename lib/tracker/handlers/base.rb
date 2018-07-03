class Tracker::Handlers::Base
  class NotImplemented < StandardError; end

  attr_reader :api_key, :env, :uuid

  # Accepts:
  #   api_key      - String
  #   env          - Hash
  #   uuid_fetcher - Proc, should return String/int UUID of user.
  def initialize(api_key:"", env:, uuid_fetcher:)
    @api_key = api_key
    @env     = env
    @uuid    = uuid_fetcher.call(env)
  end

  private

  def default_page_args
    default_args.merge({
      path:       env["PATH_INFO"],
      user_agent: env["HTTP_USER_AGENT"]
    })
  end

  def default_event_args
    default_args.merge({})
  end

  def default_args
    {
      uuid:    uuid,
      user_id: env["rack.session"]["user_id"],
      host_name:  env["HTTP_HOST"]
    }
  end
end
