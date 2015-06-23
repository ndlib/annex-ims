class DropActivityLogConstraints < ActiveRecord::Migration
  def change
    remove_foreign_key :activity_logs, column: :object_item_id
    remove_foreign_key :activity_logs, column: :object_tray_id
    remove_foreign_key :activity_logs, column: :location_tray_id
    remove_foreign_key :activity_logs, column: :location_shelf_id
    remove_foreign_key :activity_logs, column: :location_bin_id
    remove_foreign_key :activity_logs, column: :user_id
  end
end
