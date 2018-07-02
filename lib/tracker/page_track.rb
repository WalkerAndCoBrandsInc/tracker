require_relative "./controller"

class PageTrack
  HTTP_ACCEPT = ["text/html"]

  include Tracker::Controller

  attr_reader :tracker, :env

  def initialize(env)
    @env = env
  end

  def track
    queue_tracker do |t|
      t.page(path: env["PATH_INFO"], page_args: {})
    end
  end
end
