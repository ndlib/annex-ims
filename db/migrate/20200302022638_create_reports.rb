class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.string :name, null: false
      t.text :fields
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :activity, null: false
      t.string :status

      t.timestamps
    end
  end
end
