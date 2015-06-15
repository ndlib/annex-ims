class GetItemDataJob < ActiveJob::Base
  queue_as :default

  def perform(barcode)
Rails.logger.info "Got here"
    item = Item.find_or_initialize_by(barcode: barcode)  # This section will need to throw things into a queue for background processing.

    if item.new_record?
      user = User.find(@user_id)
      item.thickness ||= 0
      item.save!
      LogActivity.call(item, "Created", nil, Time.now, user)
    end

    data = ApiGetItemMetadata.call(barcode)
    if data["status"] == 200
      item.attributes = data["results"]
      item.thickness ||= 0
      item.save!
    elsif data["status"] == 404 # Not found
      AddIssue.call(user_id, barcode, "Item not found.")
      item.destroy!
      item = nil
    elsif data["status"] == 401 # Unauthorized - probably bad key
      AddIssue.call(user_id, barcode, "Unauthorized - Check API Key.")
      item = nil
    elsif data["status"] == 599 # Timeout
      AddIssue.call(user_id, barcode, "API Timeout.")
      item = nil
    end

  end
end
