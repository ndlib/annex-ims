class CreateMatches < ActiveRecord::Migration[4.2]
  class Item < ApplicationRecord
  end

  class Batch < ApplicationRecord
    has_and_belongs_to_many :items
  end

  class Request < ApplicationRecord
    belongs_to :batch
  end

  def up
    Batch.all.each do |b|
      b.items = []
      b.save!
    end

    Request.all.each do |r|
      r.batch = nil
      r.save!
    end

    add_column :batches_items, :id, :primary_key
    add_column :batches_items, :request_id, :integer, null: false
    rename_table :batches_items, :matches

    remove_index :matches, [:item_id, :batch_id]
    add_index :matches, [:item_id, :request_id, :batch_id], unique: true

    add_foreign_key :matches, :requests

  end

  def down
    remove_foreign_key :matches, :requests
    remove_index :matches, [:item_id, :request_id, :batch_id]
    add_index :matches, [:item_id, :batch_id], unique: true
    rename_table :matches, :batches_items

    remove_column :batches_items, :request_id
    remove_column :batches_items, :id
  end
end
