class FixRequiredFieldsRequests < ActiveRecord::Migration
  def change
    change_column_null :requests, :criteria_type, false
    change_column_null :requests, :criteria, false
    change_column_null :requests, :rapid, false
    change_column_null :requests, :source, false
    change_column_null :requests, :req_type, false
  end
end
