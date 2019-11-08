class CreateActivityLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :activity_logs do |t|
      t.string :object_barcode, null: false
      t.string :object_type, null: false
      t.integer :object_item_id, index: true
      t.integer :object_tray_id, index: true
      t.string :action, null: false
      t.string :location_barcode
      t.string :location_type
      t.integer :location_tray_id, index: true
      t.integer :location_shelf_id, index: true
      t.integer :location_bin_id, index: true
      t.timestamp :action_timestamp, null: false
      t.string :username, null: false
      t.integer :user_id, index: true, null: false

      t.timestamps null: false
    end

    add_foreign_key :activity_logs, :items, column: :object_item_id
    add_foreign_key :activity_logs, :trays, column: :object_tray_id
    add_foreign_key :activity_logs, :trays, column: :location_tray_id
    add_foreign_key :activity_logs, :shelves, column: :location_shelf_id
    add_foreign_key :activity_logs, :bins, column: :location_bin_id
    add_foreign_key :activity_logs, :users, column: :user_id
  end
end
