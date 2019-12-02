class DissociateShelfFromItem
  attr_reader :item, :user

  def self.call(item, user)
    new(item, user).dissociate!
  end

  def initialize(item, user)
    @item = item
    @user = user
  end

  def dissociate!
    DissociateTrayFromItem.call(item, user)
  end
end
