class ReindexItems < ActiveRecord::Migration
  def change
    Item.reindex
    Sunspot.commit
  end
end
