module ActivityLogQuery
  module_function

  def item_history(item)
    for_item(item).
      where(action: ["StockedItem", "UnstockedItem", "CreatedItem", "DestroyedItem"]).
      order(action_timestamp: :desc)
  end

  def item_usage(item)
    for_item(item).
      where(action: ["ScannedItem", "ShippedItem"]).
      order(action_timestamp: :desc)
  end

  def relation
    ActivityLog.all
  end

  def for_item(item)
    relation.
      where("data -> 'item' ->> 'barcode' = ?", item.barcode)
  end
  private_class_method :relation
  private_class_method :for_item
end
