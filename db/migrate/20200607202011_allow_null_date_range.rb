class AllowNullDateRange < ActiveRecord::Migration[5.2]
  def change
    change_column :reports, :start_date, :date, :null => true
    change_column :reports, :end_date, :date, :null=> true
  end
end
