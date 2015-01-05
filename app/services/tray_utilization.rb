class TrayUtilization
  attr_reader :tray

  def self.call(tray)
    new(tray).utilization
  end

  def initialize(tray)
    @tray = tray
  end

  def utlization

  end

end
