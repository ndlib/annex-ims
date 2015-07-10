module BinType
  def self.call(barcode)
    /#{IsBinBarcode::PREFIX}/.match(barcode)[2]
  end
end
