class  AssociateTrayWithShelfBarcode
  attr_reader :tray, :barcode

  def self.call(tray, barcode)
    new(tray, barcode).associate!
  end

  def initialize(tray, barcode)
    @tray = tray
    @barcode = barcode
  end

  def associate!
    validate_input!

    shelf = GetShelfFromBarcode.call(barcode)
    tray.shelf = shelf

    if tray.save
      ShelveTray.call(tray)
      tray
    else
      false
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
