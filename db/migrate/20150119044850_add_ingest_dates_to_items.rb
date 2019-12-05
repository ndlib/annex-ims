class AddIngestDatesToItems < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :initial_ingest, :date
    add_column :items, :last_ingest, :date
  end
end
