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
    item.destroy!
    LogActivity.call(item, "Destroyed", nil, Time.now, user)
  end
end
