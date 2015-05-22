class ApiPostStockItem
  attr_reader :item_id

  def self.call(item_id)
    new(item_id).post_data!
  end

  def initialize(item_id)
    @item_id = item_id
    @path = "/1.0/resources/items/stock"
  end

  def post_data!
    item = Item.find(@item_id)

    params = {item_id: @item_id, barcode: item.barcode, tray_code: item.tray.barcode}
    raw_results = ApiHandler.call("POST", @path, params)
    results = {"status" => raw_results["status"], "results" => {}}
    raw_results
  end

end
