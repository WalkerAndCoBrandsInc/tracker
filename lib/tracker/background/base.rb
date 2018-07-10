class Tracker::Background::Base
  def self.q(*args)
    raise Tracker::NotImplemented
  end
end
