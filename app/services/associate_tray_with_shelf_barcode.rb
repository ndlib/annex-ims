class  AssociateTrayWithShelfBarcode
  attr_reader :tray, :barcode, :user

  def self.call(tray, barcode, user)
    new(tray, barcode, user).associate!
  end

  def initialize(tray, barcode, user)
    @tray = tray
    @barcode = barcode
    @user = user
  end

  def associate!
    validate_input!

    shelf = GetShelfFromBarcode.call(barcode)
    tray_size = TraySize.call(tray.barcode)

    if (shelf.size.nil?) or (shelf.size == tray_size)
      tray.shelf = shelf
      shelf.size = tray_size

      if tray.save
        LogActivity.call(tray, "Associated", tray.shelf, Time.now, user)
        ShelveTray.call(tray, user)
        shelf.save
        result = tray
      else
        result = false
      end
    else
      raise "tray sizes must match"
    end

    return result
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
