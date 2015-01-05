class AddStockedToItems < ActiveRecord::Migration
  def change
    add_column :items, :stocked, :boolean, :null => false, :default => false
  end
end
