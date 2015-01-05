class TraySize
  PREFIX = '(TRAY-)([A-Z])'

  attr_reader :barcode

  def self.call(barcode)
    new(barcode).size
  end

  def initialize(barcode)
    @barcode = barcode
  end

  def size
    /#{PREFIX}/.match(barcode)[2]
  end

end
