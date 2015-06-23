class AdjustIsbnIssnColumns < ActiveRecord::Migration
  def change
    remove_column :items, :issn, :string
    rename_column :items, :isbn, :isbn_issn
  end
end
