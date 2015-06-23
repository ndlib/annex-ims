class TraySize
  attr_reader :barcode

  def self.call(barcode)
    new(barcode).size
  end

  def initialize(barcode)
    @barcode = barcode
  end

  def size
    /#{IsTrayBarcode::PREFIX}/.match(barcode)[2]
  end

end
