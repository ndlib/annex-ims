class AddTransactionToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :trans, :string
    add_index :requests, :trans, unique: true
  end
end
