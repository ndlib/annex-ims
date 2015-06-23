class AddFieldsToRequests < ActiveRecord::Migration
  def change
    add_column :requests, :title, :string
    add_column :requests, :article_title, :string
    add_column :requests, :author, :string
    add_column :requests, :description, :string
    add_column :requests, :barcode, :string
    add_column :requests, :isbn_issn, :string
    add_column :requests, :bib_number, :string
  end
end
