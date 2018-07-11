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
    d = DeviceDetector.new(request.user_agent)
    default_args
      .merge(params)
      .merge({
        path:               request.path_info,
        referrer:           request.referrer,
        user_agent:         request.user_agent,
        ua_name:            d.name,
        ua_full_version:    d.full_version,
        ua_os_name:         d.os_name,
        ua_os_full_version: d.os_full_version,
        ua_device_name:     d.device_name,
        ua_device_type:     d.device_type
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
      user_id:   user_id_from_session,
      host_name: request.env["HTTP_HOST"]
    }
  end

  def user_id_from_session
    request.session["user_id"]
  end
end
