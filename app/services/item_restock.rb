class ItemRestock
  attr_reader :user_id, :item_id, :barcode

  def self.call(user_id, item_id, barcode)
    new(user_id, item_id, barcode).process!
  end

  def initialize(user_id, item_id, barcode)
    @user_id = user_id
    @item_id = item_id
    @barcode = barcode
  end

  def process!
    results = {}
    results[:error] = nil
    results[:notice] = nil
    results[:path] = nil

    if IsItemBarcode.call(barcode)
      results = ItemPath.call(user_id, item_id, barcode)

    elsif IsTrayBarcode.call(barcode)
      results = ItemRestockToTray.call(item_id, barcode)

    else
      results[:error] = "scan either a new item or a tray to stock to"
      results[:path] = h.show_item_path(:id => @item_id)
    end

    return results
  end

  def h
    Rails.application.routes.url_helpers
  end

end
