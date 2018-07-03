class UUIDSetter
  include EnvHelpers

  KEY = "UUID".freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    env[KEY] = "uuid"
    env.merge!(rack_session)

    @app.call(env)
  end
end
