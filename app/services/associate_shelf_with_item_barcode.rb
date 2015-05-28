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

    tray = GetTrayFromBarcode.call("TRAY-#{@shelf.barcode}")
    AssociateTrayWithShelfBarcode.call(tray, @shelf.barcode)
    AssociateTrayWithItemBarcode.call(user_id, tray, barcode, thickness)
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
