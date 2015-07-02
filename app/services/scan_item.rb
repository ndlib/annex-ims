class ScanItem
  attr_reader :item, :user

  def self.call(item, user)
    new(item, user).scan!
  end

  def initialize(item, user)
    @item = item
    @user = user
  end

  def scan!
    validate_input!

    UnstockItem.call(item, user) # Just in case it's not already unstocked, make sure.
    LogActivity.call(item, "Scanned", item.tray, Time.now, user)

    item
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
