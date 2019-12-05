class AddWorkerColumnToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :worker, :boolean, null: false, default: false
  end
end
