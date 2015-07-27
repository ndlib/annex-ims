class ApiPostStockItem
  class ApiStockItemError < StandardError; end
  attr_reader :item

  def self.call(item:)
    new(item: item).post_data!
  end

  def initialize(item:)
    @item = item
  end

  def post_data!
    response = ApiHandler.post(action: :stock, params: params)
    ActivityLogger.api_stock_item(item: item, params: params, api_response: response)
    if response.success?
      response
    else
      raise ApiStockItemError, "Error sending stock request to API. params: #{params}, response: #{response.attributes}"
    end
  end

  private

  def params
    {
      item_id: item.id,
      barcode: item.barcode,
      tray_code: item.tray.barcode
    }
  end
end
