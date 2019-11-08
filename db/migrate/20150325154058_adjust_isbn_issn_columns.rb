class AdjustIsbnIssnColumns < ActiveRecord::Migration[4.2]
  def change
    remove_column :items, :issn, :string
    rename_column :items, :isbn, :isbn_issn
  end
end
