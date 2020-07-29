class ReportStatusFields < ActiveRecord::Migration[5.2]
  def change
    rename_column :reports, :status, :request_status
    add_column :reports, :item_status, :string
  end
end
