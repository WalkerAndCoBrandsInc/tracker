module EnvHelpers
  def env
    {
      "HTTP_HOST"       => "localhost:3000",
      "PATH_INFO"       => "/",
      "HTTP_USER_AGENT" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6)",
      UUIDSetter::KEY   => UUIDSetter::VALUE
    }.merge(rack_session)
  end

  def rack_session
    { "rack.session" => { "user_id" => 1 } }
  end

  def uuid_fetcher
    proc { env[UUIDSetter::KEY] }
  end
end
