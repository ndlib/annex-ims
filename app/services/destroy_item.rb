class DestroyItem
  attr_reader :item, :user

  def self.call(item, user)
    new(item, user).destroy
  end

  def initialize(item, user)
    @item = item
    @user = user
  end

  def destroy
    status = item.destroy!
    ActivityLogger.destroy_item(item: item, user: user)
    status
  end
end
