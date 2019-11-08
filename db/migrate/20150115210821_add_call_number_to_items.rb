class AddCallNumberToItems < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :call_number, :string
  end
end
