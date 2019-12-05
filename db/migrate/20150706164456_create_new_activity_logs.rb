class CreateNewActivityLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :activity_logs do |t|
      t.string :action, index: true, null: false
      t.jsonb :data, null: false
      t.timestamp :action_timestamp, index: true, null: false
      t.string :username, index: true
      t.integer :user_id, index: true

      t.timestamps null: false
    end
  end
end
