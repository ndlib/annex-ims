class AddShelvedToTrays < ActiveRecord::Migration[4.2]
  def change
    add_column :trays, :shelved, :boolean, :null => false, :default => false
  end
end
