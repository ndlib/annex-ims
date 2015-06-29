class ApiPostStockItem
  attr_reader :item_id

  def self.call(item_id)
    new(item_id).post_data!
  end

  def initialize(item_id)
    @item_id = item_id
  end

  def post_data!
    ApiHandler.post(action: :stock, params: params)
  end

  private

  def params
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
