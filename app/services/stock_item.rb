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
    ApiStockItemJob.perform_later(item: item)

    if item.save!
      ActivityLogger.stock_item(item: item, tray: item.tray, user: user)
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
