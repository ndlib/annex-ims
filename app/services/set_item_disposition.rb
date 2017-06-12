class SetItemDisposition
  attr_reader :item_id, :disposition_id

  def self.call(item_id, disposition_id)
    new(item_id, disposition_id).set
  end

  def initialize(item_id, disposition_id)
    @item = Item.where(id: item_id).take
    @disposition = Disposition.where(id: disposition_id).take
  end

  def set
    @item.disposition = @disposition
    @item.save!
    ActivityLogger.set_item_disposition(item: @item, disposition: @disposition) 
  end
end
