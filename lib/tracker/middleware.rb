require_relative "./page_track"
require "device_detector"

module Tracker
  DeferedInitializer = Struct.new(:queuer_class, :client_class, :opts)

  class Middleware
    HTTP_ACCEPT_HTML = "text/html"

    attr_reader :app, :handlers

    KEY = "tracker".freeze
    IGNORE_STATUS = [404].freeze

    def initialize(app, &block)
      @app      = app
      @handlers = []
      @ignore_paths = []

      instance_exec(&block) if block_given?

      Tracker.middle_instance = self
    end

    def call(env)
      env[KEY] = self # needs to be before app.call
      s, h, o = app.call(env) # needs to be before track
      track_page(env) if should_track?(s, env)

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

    def ignore_paths(paths=[])
      return @ignore_paths unless paths.any?
      @ignore_paths = paths
    end

    def session(&blk)
      return @session_fetcher if blk.nil?
      @session_fetcher = blk
    end

    private

    def track_page(env)
      Tracker::PageTrack.new(env).track
    end

    def matchers_ignore_paths
      @matchers_ignore_paths ||= @ignore_paths.map do |p|
        parsed = p.gsub('*','.*').gsub('/', '\/')
        if parsed[-2..-1] == '.*'
          Regexp.new("^#{parsed}")
        else
          Regexp.new("^#{parsed}$")
        end
      end
    end

    def path_in_ignore_paths?(path)
      return false unless @ignore_paths.any?
      return true if matchers_ignore_paths.any? { |m| m.match(path) }
      false
    end

    def should_track?(status, env)
      return false if path_in_ignore_paths?(env["REQUEST_PATH"] || env["PATH_INFO"])
      return false if IGNORE_STATUS.include?(status)
      return false if env["HTTP_ACCEPT"] && !env["HTTP_ACCEPT"].include?(HTTP_ACCEPT_HTML)
      return false if DeviceDetector.new(env["HTTP_USER_AGENT"]).bot?

      true
    end
  end
end
