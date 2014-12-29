class  AssociateTrayWithItemBarcode
  attr_reader :tray, :barcode, :thickness

  def self.call(tray, barcode, thickness)
    new(tray, barcode, thickness).associate!
  end

  def initialize(tray, barcode, thickness)
    @tray = tray
    @barcode = barcode
    @thickness = thickness
  end

  def associate!
    validate_input!

    item = GetItemFromBarcode.call(barcode)
    if !item.nil?
      item.tray = tray
      item.thickness = thickness
      if item.save
        return item
      else
        return false
      end
    else
      raise "item not found"
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
