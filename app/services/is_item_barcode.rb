module IsItemBarcode
  def self.call(barcode)
    !(IsTrayBarcode.call(barcode) || IsShelfBarcode.call(barcode) || IsBinBarcode.call(barcode))
  end
end
