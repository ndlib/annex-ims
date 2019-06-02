class ShelfFull
  attr_reader :tray_type, :shelf

  def self.call(tray_type, shelf)
    new(tray_type, shelf).full?
  end

  def initialize(tray_type, shelf)
    @tray_type = tray_type
    @shelf = shelf
  end

  def full?
    @shelf.trays.count >= @tray_type.trays_per_shelf
  end
end
