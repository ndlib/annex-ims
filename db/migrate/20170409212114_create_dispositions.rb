class CreateDispositions < ActiveRecord::Migration
  def change
    create_table :dispositions do |t|
      t.string :name, null: false
      t.string :description
      t.boolean :active, null: false, default: true

      t.timestamps null: false
    end
  end
end
