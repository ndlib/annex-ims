class AddDelTypeToRequest < ActiveRecord::Migration[4.2]
  def change
    add_column :requests, :del_type, :string, null: false, default: ''
  end
end
