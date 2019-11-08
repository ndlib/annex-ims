class AddBatchToRequest < ActiveRecord::Migration[4.2]
  def change
    add_reference :requests, :batch, index: true
    add_foreign_key :requests, :batches
  end
end
