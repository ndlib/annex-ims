class ItemPath
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

    item = GetItemFromBarcode.call(barcode: barcode, user_id: user_id)

    if item.blank?
      results[:error] = "No item was found with barcode #{barcode}"
      results[:path] = h.show_item_path(:id => @item_id)
    else
      results[:path] = h.show_item_path(:id => item.id)
    end

    return results
  end

  def h
    Rails.application.routes.url_helpers
  end

end
