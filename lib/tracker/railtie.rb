class Tracker::Railtie < ::Rails::Railtie
  initializer "tracker.configure_controller" do |app|
    ActiveSupport.on_load :action_controller do
      include Tracker::Controller
    end
  end
end
