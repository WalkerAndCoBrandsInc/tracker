require_relative './env_helpers'

class UUIDSetter
  KEY   = "UUID".freeze
  VALUE = "uuid".freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    env[KEY] = VALUE
    env.merge!(rack_session)

    @app.call(env)
  end

  def env
    {
      UUIDSetter::KEY             => UUIDSetter::VALUE,
      "HTTP_HOST"                 => "localhost:3000",
      "PATH_INFO"                 => "/",
      "HTTP_USER_AGENT"           => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6)",
      "REQUEST_URI"               => "/?utm_param=1&utm_param=2&utm_source=a",
      "QUERY_STRING"              => "utm_param=1&utm_param=2&utm_source=a",
      "rack.request.query_hash"   => {utm_param:1, utm_param:2, utm_source:"a"},
      "rack.request.query_string" => "?utm_param=1&utm_param=2&utm_source=a",
      "rack.input"                => ""
    }.merge(rack_session)
  end

  def rack_session
    { "rack.session" => { "user_id" => 1 } }
  end

  def uuid_fetcher
    proc { env[UUIDSetter::KEY] }
  end

  def env_with_request_params
    request_params = StringIO.new( "user%5Bemail%5D=overwow%40wilding.com&user%5Bpassword%5D=olusegun")
    env.merge!({ "REQUEST_METHOD" => "POST", "rack.input" => request_params})
  end
end
