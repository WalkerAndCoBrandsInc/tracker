require "uri"

class Tracker::Handlers::Base
  class NotImplemented < StandardError; end

  attr_reader :api_key, :request, :uuid

  # Accepts:
  #   api_key      - String
  #   env          - Hash
  #   uuid_fetcher - Proc, should return String/int UUID of user.
  def initialize(api_key:"", env:, uuid_fetcher:)
    @api_key = api_key
    @request = Rack::Request.new(env)
    @uuid    = uuid_fetcher.call(env)
  end

  def page(*args)
    raise NotImplemented
  end

  def event(*args)
    raise NotImplemented
  end

  private

  def default_page_args
    default_args
      .merge(params)
      .merge({
        path:       request.path_info,
        referer:    request.referer,
        user_agent: request.user_agent
    })
  end

  def params
    request.params.deep_symbolize_keys
  end

  def default_event_args
    default_args.merge({})
  end

  def default_args
    {
      uuid:      uuid,
      user_id:   request.session["user_id"],
      host_name: request.env["HTTP_HOST"]
    }
  end
end
