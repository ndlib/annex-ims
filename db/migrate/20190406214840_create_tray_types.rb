class CreateTrayTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :tray_types do |t|
      t.string :code, null: false, unique: true
      t.integer :trays_per_shelf, null: false
      t.boolean :unlimited, null: false, default: false
      t.integer :height, null: false
      t.integer :capacity, null: false
      t.boolean :active, null: false, default: true

      t.timestamps null: false
    end
  end
end
