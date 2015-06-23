class AddBatchToRequest < ActiveRecord::Migration
  def change
    add_reference :requests, :batch, index: true
    add_foreign_key :requests, :batches
  end
end
