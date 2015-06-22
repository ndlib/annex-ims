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

    PostStockDataJob.perform_later(user.id, item.id)

    return item
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
