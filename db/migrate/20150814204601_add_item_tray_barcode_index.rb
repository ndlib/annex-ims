class AddItemTrayBarcodeIndex < ActiveRecord::Migration[4.2]
  def up
    execute("create index idxgin_data_item_barcode ON
             activity_logs USING
             gin ((data -> 'item' -> 'barcode'))")

    execute("create index idxgin_data_shelf_barcode ON
             activity_logs USING
             gin ((data -> 'shelf' -> 'barcode'))")
  end

  def down
    execute("drop index idxgin_data_item_barcode")
    execute("drop index idxgin_data_shelf_barcode")
  end
end
