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

      if item.new_record?
        item.thickness ||= 0
        item.save!
        LogActivity.call(item, "Created", nil, Time.now, user)
      end

      if SyncItemMetadata.call(item: item, user_id: user_id)
        item
      else
        nil
      end
    else
      raise "barcode is not an item"
    end
  end

  private

    def user
      @user ||= User.find(user_id)
    end

    def valid?
      IsItemBarcode.call(barcode)
    end
end
