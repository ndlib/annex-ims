class  ItemRestock
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

    begin
      if IsItemBarcode.call(barcode)
        item = GetItemFromBarcode.call(barcode)

        if item.blank?
          results[:error] = "No item was found with barcode #{barcode}"
          results[:path] = h.show_item_path(:id => @item_id)
        else
          results[:path] = h.show_item_path(:id => item.id)
        end
      elsif IsTrayBarcode.call(barcode)
        item = Item.find(@item_id)
        tray = GetTrayFromBarcode.call(barcode)

        if (!item.tray.nil?) && (item.tray != tray) # this isn't the place to be putting items in the wrong tray
          raise 'incorrect tray for this item'
        end

        StockItem.call(item)
        results[:notice] = "Item #{item.barcode} stocked."
        results[:path] = h.items_path
      else
        results[:error] = "scan either a new item or a tray to stock to"
        results[:path] = h.show_item_path(:id => @item_id)
      end
    rescue StandardError => e
      results[:error] = e.message
      results[:path] = h.show_item_path(:id => @item_id)
    end

    return results
  end

  def h
    Rails.application.routes.url_helpers
  end

end
