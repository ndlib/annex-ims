class AddBatchTypeToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :batch_type, :integer, null: false, default: 0
  end
end
