class AddTrayTypeToTrays < ActiveRecord::Migration
  def change
    add_reference :trays, :tray_type, index: true, foreign_key: true
  end
end
