class CreateBins < ActiveRecord::Migration
  def change
    create_table :bins do |t|
      t.string :barcode, null: false

      t.timestamps null: false
    end
    add_index :bins, :barcode, unique: true
  end
end
