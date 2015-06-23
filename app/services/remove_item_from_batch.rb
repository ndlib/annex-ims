class RemoveItemFromBatch
  attr_reader :item_id, :batch_id

  def self.call(item_id, batch_id)
    new(item_id, batch_id).remove!
  end

  def initialize(item_id, batch_id)
    @item_id = item_id
    @batch_id = batch_id
  end

  def remove!

  end
end
