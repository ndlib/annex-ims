class AddFieldsToItems < ActiveRecord::Migration
  def change
    add_column :items, :bib_number, :string
    add_column :items, :isbn, :string
    add_column :items, :issn, :string
    add_column :items, :condition, :string
  end
end
