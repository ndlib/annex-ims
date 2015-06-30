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
        LogActivity.call(item, "Created", nil, Time.now, user)
      end
    end
  end

  def item_can_be_stocked?
    !(["not_found", "not_for_annex"].include? item.metadata_status)
  end

  def user
    @user ||= User.find(user_id)
  end

  def valid?
    IsItemBarcode.call(barcode)
  end
end
