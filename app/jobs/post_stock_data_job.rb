class PostStockDataJob < ActiveJob::Base
  queue_as :default

  def perform(user_id, item_id)
    user = User.find(user_id)
    item = Item.find(item_id)
    data = ApiPostStockItem.call(item_id)

    if data["status"] == 200
      item.stocked!
      UpdateIngestDate.call(item)
      LogActivity.call(item, "Stocked", item.tray, Time.now, user)
    elsif data["status"] == 404 # Not found
      AddIssue.call(user_id, barcode, "Item not found.")
    elsif data["status"] == 401 # Unauthorized - probably bad key
      AddIssue.call(user_id, barcode, "Unauthorized - Check API Key.")
    elsif data["status"] == 599 # Timeout
      AddIssue.call(user_id, barcode, "API Timeout.")
    end

  end

end
