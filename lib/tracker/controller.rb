module Tracker::Controller
  extend self

  def queue_tracker(&blk)
    if (t = env[Tracker::Middleware::KEY]; t)
      t.handlers.each do |h|
        t.queuer.queue(
          blk.call(h.klass.new(h.opts.merge(env: env, uuid_fetcher: t.uuid)))
        )
      end
    end
  end
end
