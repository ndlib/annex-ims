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

    item.stocked = true

    if item.save
      item
    else
      false
    end
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
