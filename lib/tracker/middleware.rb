module Tracker
  class Middleware
    attr_reader :app, :handlers

    KEY = "tracker".freeze

    def initialize(app, &block)
      @app      = app
      @handlers = []

      instance_exec(&block) if block_given?
    end

    def call(env)
      env[KEY] = self
      app.call(env)
    end

    def queuer(q=nil)
      return @queuer if q.nil?
      @queuer = q
    end

    def uuid(&blk)
      return @uuid_fetcher if blk.nil?
      @uuid_fetcher = blk
    end
  end
end
