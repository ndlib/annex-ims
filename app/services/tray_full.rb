class TrayFull
  TRAY_LIMIT = 40

  attr_reader :tray

  def self.call(tray)
    new(tray).full?
  end

  def initialize(tray)
    @tray = tray
  end

  def full?
    (@tray.items.sum(:thickness) > (TRAY_LIMIT + @tray.items.count))
  end

end
