class AddBatchTypeToBatch < ActiveRecord::Migration[4.2]
  def change
    add_column :batches, :batch_type, :integer, null: false, default: 0
  end
end
