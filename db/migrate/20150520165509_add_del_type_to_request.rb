class AddDelTypeToRequest < ActiveRecord::Migration
  def change
    add_column :requests, :del_type, :string, null: false
  end
end
