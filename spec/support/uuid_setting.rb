class UUIDSetter
  KEY = "UUID".freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    env[KEY] = "1"
    @app.call(env)
  end
end
