require "uri"

class Tracker::Handlers::Base
  class NotImplemented < StandardError; end

  attr_reader :api_key, :env, :uuid, :request

  # Accepts:
  #   api_key      - String
  #   env          - Hash
  #   uuid_fetcher - Proc, should return String/int UUID of user.
  #   uuid         - String (Optional)
  def initialize(api_key:"", env:, uuid_fetcher: -> proc {}, uuid: nil)
    @api_key = api_key
    @env     = env
    @request = Rack::Request.new(env)
    @uuid    = uuid || uuid_fetcher.call(env)
  end

  def page(*args)
    raise NotImplemented
  end

  def event(*args)
    raise NotImplemented
  end

  def conversion(*args)
    raise NotImplemented
  end

  private

  def default_page_args
    d = DeviceDetector.new(env["HTTP_USER_AGENT"])
    default_args
      .merge(params)
      .merge(request_params)
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

  def request_params
    # pass {} instead of nil to avoid exception
    if (env['REQUEST_METHOD']  == 'POST' || env['REQUEST_METHOD']  == 'PUT')
      sanitized_params = request.params.deep_symbolize_keys
      sanitized_params[:user].delete(:password) if sanitized_params[:user] && sanitized_params[:user][:password].present?
    end

    sanitized_params || {}
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

  def default_conversion_args
    default_args.except(:host_name)
  end

  def user_id_from_session
    env["rack.session"]["user_id"] if env["rack.session"]
  end
end
