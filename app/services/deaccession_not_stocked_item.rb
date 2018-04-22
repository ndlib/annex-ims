class DeaccessionNotStockedItem
  def self.call(request_id, item_id, disposition_id, user)
    new.deaccession(request_id, item_id, disposition_id, user)
  end

  def deaccession(request_id, item_id, disposition_id, user)
    batch = BuildBatch.call(["#{request_id}-#{item_id}"], user, 1)
    bin = GetBinFromBarcode.call("BIN-REM-HAND-01")
    SetItemDisposition.call(item_id, disposition_id)
    item = Item.where(id: item_id).take
    item.bin = bin
    item.save!
    ActivityLogger.associate_item_and_bin(item: item, bin: bin, user: user)
    match = Match.includes(:item).where(items: {id: item.id}).first
    match.bin = bin
    match.save!
  end
end
