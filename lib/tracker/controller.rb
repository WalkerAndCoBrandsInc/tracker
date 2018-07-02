module Tracker::Controller
  extend self

  def queue_tracker(&blk)
    if (t = env[Tracker::Middleware::KEY]; t)
      t.handlers.each do |handler|
        t.queuer.queue(
          handler.client_class.to_s,
          blk.call(
            handler.queuer_class.new(handler.opts.merge(env: env, uuid_fetcher: t.uuid))
          )
        )
      end
    end
  end
end
