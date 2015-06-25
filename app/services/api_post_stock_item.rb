class ApiPostStockItem
  API_PATH = "/1.0/resources/items/stock"

  attr_reader :item_id

  def self.call(item_id)
    new(item_id).post_data!
  end

  def initialize(item_id)
    @item_id = item_id
  end

  def post_data!
    ApiHandler.post(API_PATH, post_params)
  end

  private

  def post_params
    {
      item_id: item.id,
      barcode: item.barcode,
      tray_code: item.tray.barcode
    }
  end

  def item
    @item ||= Item.find(item_id)
  end

end
