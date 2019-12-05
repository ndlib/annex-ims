class DropOriginalActivityLogs < ActiveRecord::Migration[4.2]
  def change
    drop_table :activity_logs
  end
end
