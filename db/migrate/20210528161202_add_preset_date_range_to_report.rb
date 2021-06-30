class AddPresetDateRangeToReport < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :preset_date_range, :string
  end
end
