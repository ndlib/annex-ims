class AssociateShelfWithItemBarcode
  attr_reader :user_id, :shelf, :barcode, :thickness

  def self.call(user_id, shelf, barcode, thickness)
    new(user_id, shelf, barcode, thickness).associate!
  end

  def initialize(user_id, shelf, barcode, thickness)
    @user_id = user_id
    @shelf = shelf
    @barcode = barcode
    @thickness = thickness
  end

  def associate!
    validate_input!

    item = GetItemFromBarcode.call(user_id, barcode)
    if !item.nil?
      tray = GetTrayFromBarcode.call("TRAY-#{@shelf.barcode}")
      item.tray = tray
      tray.shelf = shelf
      item.thickness = thickness
      if item.save
        StockItem.call(item)
        tray.save!
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
      if IsObjectShelf.call(shelf)
        true
      else
        raise "object is not a shelf"
      end
    end

  end
