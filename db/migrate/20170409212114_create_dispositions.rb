class CreateDispositions < ActiveRecord::Migration[4.2]
  def change
    create_table :dispositions do |t|
      t.string :name, null: false
      t.string :description
      t.boolean :active, null: false, default: true

      t.timestamps null: false
    end
  end
end
