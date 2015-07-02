class ShipItem
  attr_reader :item, :user, :request

  def self.call(item:, request:, user:)
    new(item: item, request: request, user: user).ship!
  end

  def initialize(item:, request:, user:)
    @item = item
    @user = user
    @request = request
  end

  def ship!
    validate_input!

    item.shipped!

    if item.save!
      ActivityLogger.ship_item(item: item, request: request, user: user)
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
