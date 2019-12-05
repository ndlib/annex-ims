class CreateRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :requests do |t|
      t.string :criteria_type
      t.string :criteria
      t.references :item, index: true
      t.date :requested

      t.timestamps null: false
    end
    add_foreign_key :requests, :items
  end
end
