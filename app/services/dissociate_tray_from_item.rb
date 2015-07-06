class DissociateTrayFromItem
  attr_reader :item, :user

  def self.call(item, user)
    new(item, user).dissociate!
  end

  def initialize(item, user)
    @item = item
    @user = user
  end

  def dissociate!
    tray = item.tray
    unless UnstockItem.call(item, user)
      raise "unable to unstock item"
    end

    item.tray = nil

    if item.save
      ActivityLogger.dissociate_item_and_tray(item: item, tray: tray, user: user)
      item
    else
      false
    end
  end


  private

    def transaction_log
      # log transaction here
    end

end
