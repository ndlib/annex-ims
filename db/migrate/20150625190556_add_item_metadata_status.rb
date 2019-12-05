class AddItemMetadataStatus < ActiveRecord::Migration[4.2]
  def change
    add_column :items, :metadata_updated_at, :datetime
    add_column :items, :metadata_status, :string, limit: 20, default: "pending"
  end
end
