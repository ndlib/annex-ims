module IsObjectTray
  CLASS_NAME = "Tray".freeze
  def self.call(tray)
    tray.class.to_s == CLASS_NAME
  end
end
