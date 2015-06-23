class CreateShelves < ActiveRecord::Migration
  def change
    create_table :shelves do |t|
      t.string :barcode

      t.timestamps null: false
    end
    add_index :shelves, :barcode, unique: true
  end
end
