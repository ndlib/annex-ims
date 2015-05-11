class ApiPostStockItem
  attr_reader :item_id, :barcode, :tray_code

  def self.call(item_id, barcode, tray_code)
    new(item_id, barcode, tray_code).post_data!
  end

  def initialize(item_id, barcode, tray_code)
    @item_id = item_id
    @barcode = barcode
    @tray_code = tray_code
    @path = "/1.0/resources/items/stock"
  end

  def post_data!
    validate_input!

    params = {item_id: @item_id, barcode: @barcode, tray_code: @tray_code}
    raw_results = ApiHandler.call("POST", @path, params)
    results = {"status" => raw_results["status"], "results" => {}}
    raw_results
  end

  private

    def validate_input!
      if IsItemBarcode.call(barcode)
        if IsTrayBarcode.call(tray_code)
          return true
        else
          raise "tray code is not a tray"
        end
      else
        raise "barcode is not an item"
      end
    end

end
