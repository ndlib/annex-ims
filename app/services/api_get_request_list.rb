class ApiGetRequestList
  class ApiGetRequestsError < StandardError; end

  def self.call
    new.get_data!
  end

  def initialize
  end

  def get_data!
    requests = []

    response = ApiHandler.get(action: :active_requests)
    if response.success?
      response
    else
      raise ApiGetRequestsError, "Error getting active requests from API. response: #{response.inspect}"
    end
  end
end
