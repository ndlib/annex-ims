module IsItemBarcode
  def self.call(barcode)
    return false unless barcode.present?
    return false if IsTrayBarcode.call(barcode)
    return false if IsShelfBarcode.call(barcode)
    return false if IsBinBarcode.call(barcode)
    true
  end
end
