class AddBarcodeTypeToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :barcode_type, :string
    execute("update issues set barcode_type='item'")
    change_column :issues, :barcode_type, :string, null: false
  end
end
