class ChangeTrayTypeCapacityNullable < ActiveRecord::Migration[4.2]
  def change
    change_column_null(:tray_types, :capacity, true)

    add_index :tray_types, :code, unique: true
  end
end
