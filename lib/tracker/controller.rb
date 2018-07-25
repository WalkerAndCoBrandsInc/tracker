module Tracker::Controller
  extend self

  def queue_tracker(&blk)
    if (t = env[Tracker::Middleware::KEY]; t)
      t.handlers.each do |handler|
        args = blk.call(
          handler.queuer_class.new(handler.opts.merge(env: env, uuid_fetcher: t.uuid))
        )

        next unless args

        t.queuer.q(
          handler.client_class.to_s,
          args
        )
      end
    end
  end
end
