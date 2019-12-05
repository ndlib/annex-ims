class AddActiveToBatches < ActiveRecord::Migration[4.2]
  def change
    add_column :batches, :active, :boolean, :null => false, :default => true
  end
end
