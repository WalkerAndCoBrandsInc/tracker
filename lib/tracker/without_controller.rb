module Tracker::WithoutController
  extend self

  def queue_tracker(env: {}, uuid: nil, &blk)
    if (t = Tracker.middle_instance; t)
      t.handlers.each do |handler|
        args = blk.call(
          handler.queuer_class.new(handler.opts.merge(env: env, uuid: uuid))
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
