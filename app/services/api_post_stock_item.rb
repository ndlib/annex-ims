class ApiPostStockItem
  attr_reader :item

  def self.call(item: item)
    new(item: item).post_data!
  end

  def initialize(item: item)
    @item = item
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

end
