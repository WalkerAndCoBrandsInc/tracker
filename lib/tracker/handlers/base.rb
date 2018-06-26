class Tracker::Handlers::Base
  class NotImplemented < StandardError; end

  # Accepts:
  #   api_key - String
  def initalize(api_key:)
    @api_key = api_key
  end

  # Accepts:
  #   path   - String
  #   params - (Optional) Hash
  def page(path:, params:{})
    raise NotImplemented
  end

  # Accepts:
  #   name   - String
  #   params - (Optional) Hash
  def event(name:, params:{})
    raise NotImplemented
  end
end
