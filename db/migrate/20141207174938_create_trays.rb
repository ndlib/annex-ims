class CreateTrays < ActiveRecord::Migration[4.2]
  def change
    create_table :trays do |t|
      t.string :barcode
      t.references :shelf, index: true

      t.timestamps null: false
    end
    add_index :trays, :barcode, unique: true
    add_foreign_key :trays, :shelves
  end
end
