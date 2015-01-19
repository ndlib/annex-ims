class AddIngestDatesToItems < ActiveRecord::Migration
  def change
    add_column :items, :initial_ingest, :date
    add_column :items, :last_ingest, :date
  end
end
