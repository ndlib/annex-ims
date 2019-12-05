class ShelfFull
  EMPTY = 0
  PARTIAL = 1
  FULL = 2
  OVER = 3

  attr_reader :shelf

  def self.call(shelf)
    new(shelf).full?
  end

  def initialize(shelf)
    @shelf = shelf
  end

  def full?
    return EMPTY if @shelf.trays.count == 0
    return FULL if @shelf.trays.count == @shelf.tray_type.trays_per_shelf
    return OVER if @shelf.trays.count > @shelf.tray_type.trays_per_shelf

    PARTIAL
  end
end
