class ApiPostDeaccessionItem
  class ApiDeaccessionItemError < StandardError; end
  attr_reader :item

  def self.call(item:)
    new(item: item).post_data!
  end

  def initialize(item:)
    @item = item
  end

  def post_data!
    response = ApiHandler.post(action: :deaccession, params: params)
    ActivityLogger.api_deaccession_item(item: item, params: params, api_response: response)
    if response.success?
      response
    else
      handle_error(response)
    end
  end

  private

  def handle_error(response)
    if (response.status_code == 422) || (response.status_code == 404)
      AddIssue.call(item: item, user: nil, type: "aleph_error", message: response.body["message"])
    end
    raise ApiDeaccessionItemError, "Error sending deaccession request to API. params: #{params}, response: #{response.attributes}"
  end

  def params
    {
      barcode: item.barcode
    }
  end
end
