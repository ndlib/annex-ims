class AddPatronFieldsToRequests < ActiveRecord::Migration[4.2]
  def change
    add_column :requests, :patron_institution, :string
    add_column :requests, :patron_department, :string
    add_column :requests, :patron_status, :string
    add_column :requests, :pickup_location, :string
  end
end
