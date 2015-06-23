class AddCallNumberToItems < ActiveRecord::Migration
  def change
    add_column :items, :call_number, :string
  end
end
