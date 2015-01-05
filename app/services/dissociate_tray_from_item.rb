class DissociateTrayFromItem
  attr_reader :item

  def self.call(item)
    new(item).dissociate!
  end

  def initialize(item)
    @item = item
  end

  def dissociate!
    item.tray = nil

    unless UnstockItem.call(@item)
      raise "unable to unstock item"
    end

    if item.save
      transaction_log
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
