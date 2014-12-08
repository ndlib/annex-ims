class UpdateCoreFields < ActiveRecord::Migration
  def change
    change_column_null :trays, :barcode, false
    change_column_null :shelves, :barcode, false
    change_column_null :items, :barcode, false

    rename_column :items, :width, :thickness
  end
end
