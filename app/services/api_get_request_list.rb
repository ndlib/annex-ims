class ApiGetRequestList
  class ApiGetRequestsError < StandardError; end

  def self.call
    new.get_data!
  end

  def initialize
  end

  def get_data!
    response = ApiHandler.get(action: :active_requests)
    log_activity(response)
    if response.success?
      response
    else
      raise ApiGetRequestsError, "Error getting active requests from API. response: #{response.inspect}"
    end
  end

  private

  def log_activity(response)
    # The body of the api response is too large to justify logging every time this is called
    # Log a new response object to make sure we have the status code.
    logged_response = ApiResponse.new(status_code: response.status_code, body: {})
    ActivityLogger.api_get_request_list(api_response: logged_response)
  end
end
