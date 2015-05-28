class ShipItem
  attr_reader :item

  def self.call(item)
    new(item).ship!
  end

  def initialize(item)
    @item = item
  end

  def ship!
    validate_input!

    item.shipped!

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
