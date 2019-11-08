class AddFieldsToItems < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :bib_number, :string
    add_column :items, :isbn, :string
    add_column :items, :issn, :string
    add_column :items, :conditions, :text, array: true, default: []
  end
end
