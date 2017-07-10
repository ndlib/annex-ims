class DeaccessionNotStockedItem
  def self.call(request_id, item_id, disposition_id, user)
    new.deaccession(request_id, item_id, disposition_id, user)
  end

  def deaccession(request_id, item_id, disposition_id, user)
    batch = BuildBatch.call(["#{request_id}-#{item_id}"], user)
    ProcessMatch.call(match: batch.matches.first, user: user)
    FinishBatch.call(batch, user)
    bin = GetBinFromBarcode.call("BIN-DEAC-HAND-01")
    SetItemDisposition.call(item_id, disposition_id)
    item = Item.where(id: item_id).take
    item.bin = bin
    item.save!
    ActivityLogger.associate_item_and_bin(item: item, bin: bin, user: user)
  end
end
