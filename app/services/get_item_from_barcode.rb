class GetItemFromBarcode
  attr_reader :user_id, :barcode

  def self.call(barcode:, user_id:)
    new(barcode: barcode, user_id: user_id).get
  end

  def initialize(barcode:, user_id:)
    @user_id = user_id
    @barcode = barcode
  end

  def get
    if valid?
      SyncItemMetadata.call(item: item, user_id: user_id)

      if item_can_be_stocked?
        item
      end
    else
      raise "barcode is not an item"
    end
  end

  private

  def item
    @item ||= find_or_create_item
  end

  def find_or_create_item
    Item.find_or_initialize_by(barcode: barcode) do |item|
      if item.new_record?
        item.thickness ||= 0
        item.save!
        ActivityLogger.create_item(item: item, user: user)
      end
    end
  end

  def item_can_be_stocked?
    !(["not_found", "not_for_annex"].include? item.metadata_status)
  end

  def user
    if user_id
      @user ||= User.find(user_id)
    end
  end

  def valid?
    IsItemBarcode.call(barcode)
  end
end
