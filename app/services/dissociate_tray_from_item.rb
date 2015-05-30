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
    LogActivity.call(item, "Disassociated", item.tray, Time.now, user)

    unless UnstockItem.call(item, user)
      raise "unable to unstock item"
    end

    item.tray = nil

    if item.save!
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
