class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      # t.integer :user_id - We'll add a reference to the user table once authentication is in place.

      t.timestamps null: false
    end
  end
end
