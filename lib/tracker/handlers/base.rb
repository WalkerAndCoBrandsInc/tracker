require "uri"

class Tracker::Handlers::Base
  class NotImplemented < StandardError; end

  attr_reader :api_key, :env, :uuid

  # Accepts:
  #   api_key      - String
  #   env          - Hash
  #   uuid_fetcher - Proc, should return String/int UUID of user.
  #   uuid         - String (Optional)
  def initialize(api_key:"", env:, uuid_fetcher: -> proc {}, uuid: nil)
    @api_key = api_key
    @env     = env
    @uuid    = uuid || uuid_fetcher.call(env)
  end

  def page(*args)
    raise NotImplemented
  end

  def event(*args)
    raise NotImplemented
  end

  private

  def default_page_args
    d = DeviceDetector.new(env["HTTP_USER_AGENT"])
    default_args
      .merge(params)
      .merge({
        path:               env["PATH_INFO"],
        referrer:           env["HTTP_REFERER"],
        user_agent:         env["HTTP_USER_AGENT"],
        ua_name:            d.name,
        ua_full_version:    d.full_version,
        ua_os_name:         d.os_name,
        ua_os_full_version: d.os_full_version,
        ua_device_name:     d.device_name,
        ua_device_type:     d.device_type
    })
  end

  def params
    # pass "" instead of nil to avoid exception
    CGI.parse(env["QUERY_STRING"] || "").deep_symbolize_keys
  end

  def default_event_args
    default_args.merge({})
  end

  def default_args
    {
      uuid:      uuid,
      user_id:   user_id_from_session,
      host_name: env["HTTP_HOST"]
    }
  end

  def user_id_from_session
    env["rack.session"]["user_id"] if env["rack.session"]
  end
end
