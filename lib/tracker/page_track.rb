require_relative "./controller"

class Tracker::PageTrack
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
