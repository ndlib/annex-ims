class StockItem
  attr_reader :item, :user

  def self.call(item, user)
    new(item, user).stock!
  end

  def initialize(item, user)
    @item = item
    @user = user
  end

  def stock!
    validate_input!

    item.stocked!
    UpdateIngestDate.call(item)
    ApiPostStockItem.call(item.id) # A bit of a hack, because when this gets shifted to a background job we only want it stocked after a successful API call. For now, this will do.

    if item.save!
      LogActivity.call(item, "Stocked", item.tray, Time.now, user)
      result = item
    else
      result = false
    end

    return result
  end

  private

    def validate_input!
      if IsObjectItem.call(item)
        true
      else
        raise "object is not an item"
      end
    end

  end
