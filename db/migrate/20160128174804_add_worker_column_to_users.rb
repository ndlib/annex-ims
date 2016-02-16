class AddWorkerColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :worker, :boolean, null: false, default: false
  end
end
