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

  def default_args
    {
      uuid:    uuid,
      user_id: env["rack.session"]["user_id"]
    }
  end
end
