require "uri"

class Tracker::Handlers::Base
  class NotImplemented < StandardError; end

  attr_reader :api_key, :env, :uuid, :session

  # Accepts:
  #   api_key      - String
  #   env          - Hash
  #   uuid_fetcher - Proc, should return String/int UUID of user.
  #   uuid         - String (Optional)
  def initialize(api_key:"", env: , uuid_fetcher: -> proc {}, uuid: nil, session_fetcher: -> proc {}, session: nil)
    @api_key = api_key
    @env     = env
    @uuid    = uuid || uuid_fetcher.call(env)
    @session = session || session_fetcher.call(env)
    env['rack.input'].rewind if env.present?
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
    return {} unless env.present?

    rack_input = env['rack.input'].read

    # This https://github.com/rack/rack/issues/337 happens with Stripe webhooks
    # where there's '%' sign in params. Since it's request params, we're simply
    # ignoring the params when this happens.
    begin
      decoded_params = Rack::Utils.parse_nested_query(rack_input).deep_symbolize_keys
      decoded_params[:user].delete(:password) if decoded_params[:user] && decoded_params[:user][:password].present?
      return decoded_params
    rescue
    end

    return {}
  ensure
    env['rack.input'].rewind if env.present?
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

  # Session information for spree is set up differently
  def user_id_from_session
    # > env["rack.session"]
    # => {
    #     "_csrf_token" => "securekey",
    #     "csrf" => "securekey",
    #     "session_id" => "securekey",
    #     "tracking" => {
    #         "HTTP_USER_AGENT" => "securekey"
    #     },
    #     "warden.user.spree_user.key" => [
    #         [0] [
    #         [0] 1
    # ],
    #     [1] "as_HVJM4J1K-QYYy_S2W"
    # ]
    # }

    return unless rack_session && warden_key && warden_ids
    warden_ids.first
  end

  def rack_session
    env["rack.session"]
  end

  def warden_key
    # this is nil if not logged in
    rack_session["warden.user.spree_user.key"]
  end

  def warden_ids
    warden_key.first
  end
end
