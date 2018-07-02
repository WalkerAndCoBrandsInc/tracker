require 'action_controller'

class MetalController < ActionController::Metal
  include Tracker::Controller
  include AbstractController::Rendering

  append_view_path File.join(File.dirname(__FILE__), '../fixtures/views')

  def index
    queue_tracker do |t|
      t.page(path: "/path", page_args: {a: 1})
    end

    render "metal/index"
  end
end
