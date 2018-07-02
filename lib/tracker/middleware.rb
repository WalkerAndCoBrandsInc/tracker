module Tracker
  DeferedInitializer = Struct.new(:queuer_class, :client_class, :opts)

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

    def handler(queue_class:, client_class:, opts: {})
      @handlers << DeferedInitializer.new(queue_class, client_class, opts)
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
