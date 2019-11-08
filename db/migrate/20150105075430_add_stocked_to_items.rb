class AddStockedToItems < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :stocked, :boolean, :null => false, :default => false
  end
end
