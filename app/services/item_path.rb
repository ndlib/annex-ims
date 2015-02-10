class ItemPath
  attr_reader :item_id, :barcode

  def self.call(item_id, barcode)
    new(item_id, barcode).process!
  end

  def initialize(item_id, barcode)
    @item_id = item_id
    @barcode = barcode
  end

  def process!
    results = {}
    results[:error] = nil
    results[:notice] = nil
    results[:path] = nil

    item = GetItemFromBarcode.call(barcode)

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
