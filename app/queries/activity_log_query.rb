module ActivityLogQuery
  module_function

  def shelf_history(shelf)
    for_shelf(shelf).
      where(action: [
        "AssociatedTrayAndShelf",
        "DissociatedTrayAndShelf",
        "ShelvedTray",
        "UnshelvedTray"]).
      order(action_timestamp: :desc)
  end

  def item_history(item)
    for_item(item).
      where(action: [
        "AcceptedItem",
        "StockedItem",
        "UnstockedItem",
        "CreatedItem",
        "CreatedIssue",
        "DestroyedItem",
        "DissociatedItemAndTray",
        "DissociatedItemAndBin",
        "ResolvedIssue",
	"DeaccessionedItem",
        "ShippedItem"]).
      order(action_timestamp: :desc)
  end

  def tray_history(tray)
    for_tray(tray).
      where(action: [
              "AssociatedTrayAndShelf",
              "CreatedTrayIssue",
              "DissociatedTrayAndShelf",
              "ResolvedTrayIssue",
              "ShelvedTray",
              "UnshelvedTray"]).
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
      where("data->'issue'->'barcode' ? :barcode OR data->'item'->'barcode' ? :barcode", barcode: item.barcode)
  end

  def for_tray(tray)
    relation.
      where("data -> 'tray' -> 'barcode' ? :barcode", barcode: tray.barcode)
  end

  def for_shelf(shelf)
    relation.
      where("data -> 'shelf' -> 'barcode' ? :barcode", barcode: shelf.barcode)
  end

  private_class_method :relation
  private_class_method :for_item
  private_class_method :for_shelf
end
