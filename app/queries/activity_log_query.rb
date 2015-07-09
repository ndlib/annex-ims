module ActivityLogQuery
  module_function

  def item_history(item)
    relation.
    where("data -> 'item' ->> 'barcode' = ?", item.barcode).
    where(action: ['StockedItem','UnstockedItem','CreatedItem','DestroyedItem']).
    order(action_timestamp: :desc)
  end

  def item_usage(item)
    relation.
    where("data -> 'item' ->> 'barcode' = ?", item.barcode).
    where(action: ['ScannedItem','ShippedItem']).
    order(action_timestamp: :desc)
  end

  def relation
    ActivityLog.all
  end
  private_class_method :relation
end