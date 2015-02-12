class TrayFull
  TRAY_LIMIT = { "AH" => 40, "AL" => 40,
                 "BH" => 40, "BL" => 40,
                 "CH" => 40, "CL" => 40,
                 "DH" => 40, "DL" => 40,
                 "EH" => 30, "EL" => 30}

  attr_reader :tray

  def self.call(tray)
    new(tray).full?
  end

  def initialize(tray)
    @tray = tray
  end

  def full?
    size = TraySize.call(@tray.barcode)
    (@tray.items.sum(:thickness) >= (TRAY_LIMIT[size] + @tray.items.count))
  end

end
