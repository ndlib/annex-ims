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
    user = User.find(user_id)
    tray = GetTrayFromBarcode.call("TRAY-#{@shelf.barcode}")
    item = GetItemFromBarcode.call(user_id, barcode)

    if tray.items.include?(item)
      StockItem.call(item, user)
    else
      AssociateTrayWithShelfBarcode.call(tray, @shelf.barcode, user)
      AssociateTrayWithItemBarcode.call(user_id, tray, barcode, thickness)
    end

    tray
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
