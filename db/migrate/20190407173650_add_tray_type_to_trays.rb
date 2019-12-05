class AddTrayTypeToTrays < ActiveRecord::Migration[4.2]
  def change
    add_reference :trays, :tray_type, index: true, foreign_key: true
  end
end
