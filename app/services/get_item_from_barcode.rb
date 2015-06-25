class GetItemFromBarcode
  attr_reader :user_id, :barcode

  def self.call(user_id, barcode)
    new(user_id, barcode).get
  end

  def initialize(user_id, barcode)
    @user_id = user_id
    @barcode = barcode
  end

  def get
    if valid?
      item = Item.find_or_initialize_by(barcode: barcode)  # This section will need to throw things into a queue for background processing.
      user = User.find(@user_id)

      if item.new_record?
        item.thickness ||= 0
        item.save!
        LogActivity.call(item, "Created", nil, Time.now, user)
      end

      data = ApiGetItemMetadata.call(barcode)
      if data["status"] == 200
        item.attributes = data["results"]
        item.thickness ||= 0
        item.save!
        LogActivity.call(item, "UpdatedByAPI", nil, Time.now, user)
      elsif data["status"] == 404 # Not found
        AddIssue.call(user_id, barcode, "Item not found.")
        DestroyItem.call(item, user)
        item = nil
      elsif data["status"] == 401 # Unauthorized - probably bad key
        AddIssue.call(user_id, barcode, "Unauthorized - Check API Key.")
        DestroyItem.call(item, user)
        item = nil
      elsif data["status"] == 599 # Timeout
        AddIssue.call(user_id, barcode, "API Timeout.")
        DestroyItem.call(item, user)
        item = nil
      end
      item
    else
      raise "barcode is not an item"
    end
  end

  private

    def valid?
      IsItemBarcode.call(barcode)
    end
end
