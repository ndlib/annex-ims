class ScanItem
  attr_reader :item, :request, :user

  def self.call(item:, request:, user:)
    new(item: item, request: request, user: user).scan!
  end

  def initialize(item:, request:, user:)
    @item = item
    @user = user
    @request = request
  end

  def scan!
    validate_input!

    ActivityLogger.scan_item(item: item, request: request, user: user)

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
