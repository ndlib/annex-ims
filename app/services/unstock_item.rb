class UnstockItem
  attr_reader :item

  def self.call(item)
    new(item).unstock!
  end

  def initialize(item)
    @item = item
  end

  def unstock!
    validate_input!

    item.stocked = false

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
