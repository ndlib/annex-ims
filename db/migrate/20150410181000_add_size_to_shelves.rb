class AddSizeToShelves < ActiveRecord::Migration
  def change
    add_column :shelves, :size, :string
  end
end
