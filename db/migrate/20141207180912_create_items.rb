class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :barcode
      t.string :title
      t.string :author
      t.string :chron
      t.integer :width
      t.references :tray, index: true

      t.timestamps null: false
    end
    add_index :items, :barcode, unique: true
    add_foreign_key :items, :trays
  end
end
