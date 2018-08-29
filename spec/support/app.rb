module App
  def app
    Rack::Builder.new do
      map "/404" do
        run Proc.new { |env| [404, {}, []] }
      end

      use UUIDSetter
      use Tracker::Middleware do
        handler(
          queue_class:  Tracker::GoogleAnalytics::Queuer,
          client_class: Tracker::GoogleAnalytics::Client,
          opts:         { api_key: "api_key" }
        )

        queuer Tracker::Background::Sidekiq

        uuid do |env|
          env[UUIDSetter::KEY]
        end

        session do |env|
          1
        end
      end

      run MetalController.action(:index)
    end
  end
end
