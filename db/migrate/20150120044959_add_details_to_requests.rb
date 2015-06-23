class AddDetailsToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :rapid, :boolean
    add_column :requests, :source, :string
    add_column :requests, :req_type, :string
  end
end
