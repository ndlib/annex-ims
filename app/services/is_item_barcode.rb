class IsItemBarcode
  attr_reader :barcode

  def self.call(barcode)
    new(barcode).compare
  end

  def initialize(barcode)
    @barcode = barcode
  end

  def compare
    !(IsTrayBarcode.call(barcode) || IsShelfBarcode.call(barcode) || IsToteBarcode.call(barcode))
  end

end
