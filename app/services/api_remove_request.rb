class ApiRemoveRequest
  attr_reader :item_id

  def self.call(request)
    new(request).post_data!
  end

  def initialize(request)
    @request = request
  end

  def post_data!
    ApiHandler.post(:archive_request, post_params)
  end

  private

  def post_params
    {
      source: @request.source,
      transaction_num: @request.trans
    }
  end
end
