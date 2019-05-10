class TrayFull
  attr_reader :tray

  def self.call(tray)
    new(tray).full?
  end

  def initialize(tray)
    @tray = tray
  end

  def full?
    return false if @tray.tray_type.unlimited
    size = TraySize.call(@tray.barcode)
    buffer = (@tray.items.count < 10) ? @tray.items.count : 10
    capacity = @tray.tray_type.capacity + buffer
    @tray.items.sum(:thickness) >= capacity
  end

end
