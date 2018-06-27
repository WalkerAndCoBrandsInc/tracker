class Tracker::Background::Base
  def self.queue(*args)
    raise Tracker::NotImplemented
  end
end
