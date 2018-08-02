require_relative './env_helpers'

class UUIDSetter
  include EnvHelpers

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
end
