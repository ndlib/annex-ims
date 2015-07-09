module IsObjectTray
  def self.call(tray)
    (tray.class.to_s == "Tray") ? true : false
  end
end
