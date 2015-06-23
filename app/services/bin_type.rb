class BinType
  attr_reader :barcode

  def self.call(barcode)
    new(barcode).kind
  end

  def initialize(barcode)
    @barcode = barcode
  end

  def kind
    /#{IsBinBarcode::PREFIX}/.match(barcode)[2]
  end

end
