class ApiRemoveRequest
  attr_reader :request

  def self.call(request:)
    new(request: request).post_data!
  end

  def initialize(request:)
    @request = request
  end

  def post_data!
    response = ApiHandler.post(action: :archive_request, params: params)
    ActivityLogger.api_remove_request(request: request, params: params, api_response: response)
    response
  end

  private

  def params
    {
      source: request.source,
      transaction_num: request.trans
    }
  end
end
