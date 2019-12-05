class AddTransactionToRequest < ActiveRecord::Migration[4.2]
  def change
    add_column :requests, :trans, :string
    add_index :requests, :trans, unique: true
  end
end
