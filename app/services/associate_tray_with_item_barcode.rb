class AssociateTrayWithItemBarcode
  attr_reader :user_id, :tray, :barcode, :thickness

  def self.call(user_id, tray, barcode, thickness)
    new(user_id, tray, barcode, thickness).associate!
  end

  def initialize(user_id, tray, barcode, thickness)
    @user_id = user_id
    @tray = tray
    @barcode = barcode
    @thickness = thickness
  end

  def associate!
    validate_input!

    item = GetItemFromBarcode.call(user_id, barcode)
    if !item.nil?
      item.tray = tray
      item.thickness = thickness
      if item.save!
        StockItem.call(item)
        return item
      else
        return false
      end
    else
      raise "item #{barcode} not found"
    end
  end

  private

    def validate_input!
      if IsObjectTray.call(tray)
        true
      else
        raise "object is not a tray"
      end
    end

  end
