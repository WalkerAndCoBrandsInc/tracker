require_relative "./page_track"
require "device_detector"

module Tracker
  DeferedInitializer = Struct.new(:queuer_class, :client_class, :opts)

  class Middleware
    HTTP_ACCEPT_HTML = "text/html"

    attr_reader :app, :handlers

    KEY = "tracker".freeze

    def initialize(app, &block)
      @app      = app
      @handlers = []

      instance_exec(&block) if block_given?
    end

    def call(env)
      env[KEY] = self # needs to be before app.call
      s, h, o = app.call(env) # needs to be before track
      track_page(env)

      return [s, h, o]
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

    private

    def track_page(env)
      return if !env["HTTP_ACCEPT"].include?(HTTP_ACCEPT_HTML)
      return if DeviceDetector.new(env["HTTP_USER_AGENT"]).bot?

      Tracker::PageTrack.new(env).track
    end
  end
end
