class TrayFull
  TRAY_LIMIT = { "AH" => 136, "AL" => 136,
                 "BH" => 136, "BL" => 136,
                 "CH" => 136, "CL" => 136,
                 "DH" => 136, "DL" => 136,
                 "EH" => 104, "EL" => 104,
                 "SHELF-" => 100000}

  attr_reader :tray

  def self.call(tray)
    new(tray).full?
  end

  def initialize(tray)
    @tray = tray
  end

  def full?
    size = TraySize.call(@tray.barcode)
    buffer = (@tray.items.count < 10) ? @tray.items.count : 10
    capacity = TRAY_LIMIT[size] + buffer
    @tray.items.sum(:thickness) >= capacity
  end

end
