class ChangeItemStocked < ActiveRecord::Migration[4.2]
  class Item < ApplicationRecord  # stocked = 0, unstocked = 1, shipped = 2, which is not the same as the boolean we had
  end

  def up
    add_column :items, :status, :integer, default: 0, null: false
    Item.reset_column_information
    Item.where(stocked: false).update_all(status: 1)
    remove_column :items, :stocked
  end

  def down
    add_column :items, :stocked, :boolean, default: false, null: false
    Item.reset_column_information
    Item.where(status: 0).update_all(stocked: true)
    remove_column :items, :status
  end
end
