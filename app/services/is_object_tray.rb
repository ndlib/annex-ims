class IsObjectTray
  attr_reader :tray

  def self.call(tray)
    new(tray).compare
  end

  def initialize(tray)
    @tray = tray
  end

  def compare
    (@tray.class.to_s == "Tray") ? true : false
  end

end
