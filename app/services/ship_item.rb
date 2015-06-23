class ShipItem
  attr_reader :item, :user

  def self.call(item, user)
    new(item, user).ship!
  end

  def initialize(item, user)
    @item = item
    @user = user
  end

  def ship!
    validate_input!

    item.shipped!

    if item.save!
      LogActivity.call(item, "Shipped", item.tray, Time.now, user)
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
