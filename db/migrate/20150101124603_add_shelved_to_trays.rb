class AddShelvedToTrays < ActiveRecord::Migration
  def change
    add_column :trays, :shelved, :boolean, :null => false, :default => false
  end
end
