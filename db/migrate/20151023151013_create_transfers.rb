class CreateTransfers < ActiveRecord::Migration[4.2]
  def change
    create_table :transfers do |t|
      t.references :shelf, index: true
      t.string :transfer_type
      t.integer :initiated_by_id
      t.timestamps null: false
    end
    add_foreign_key :transfers, :shelves
  end
end
