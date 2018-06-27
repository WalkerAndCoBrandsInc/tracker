module Tracker::Controller
  extend self

  def queue_tracker(&blk)
    if (t = env[Tracker::Middleware::KEY]; t)
      t.handlers.each do |handle|
        t.queuer.queue(
          blk.call(
            handle.klass.new(
              handle.opts.merge(env: env, uuid_fetcher: t.uuid)
            )
          )
        )
      end
    end
  end
end
