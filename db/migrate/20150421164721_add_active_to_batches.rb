class AddActiveToBatches < ActiveRecord::Migration
  def change
    add_column :batches, :active, :boolean, :null => false, :default => true
  end
end
