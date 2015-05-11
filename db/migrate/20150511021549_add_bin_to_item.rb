class AddBinToItem < ActiveRecord::Migration
  def change
    add_reference :items, :bin, index: true
    add_foreign_key :items, :bins
  end
end
