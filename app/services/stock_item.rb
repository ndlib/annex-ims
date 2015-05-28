class StockItem
  attr_reader :item

  def self.call(item)
    new(item).stock!
  end

  def initialize(item)
    @item = item
  end

  def stock!
    validate_input!

    item.stocked!
    UpdateIngestDate.call(item)
    ApiPostStockItem.call(item.id) # A bit of a hack, because when this gets shifted to a background job we only want it stocked after a successful API call. For now, this will do.

    if item.save!
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
