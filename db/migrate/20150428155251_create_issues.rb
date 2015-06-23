class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.string :barcode, null: false
      t.text :message, null: false
      t.integer :resolver_id, index: true
      t.timestamp :resolved_at

      t.timestamps null: false
    end
    add_foreign_key :issues, :users, column: :resolver_id
  end
end
