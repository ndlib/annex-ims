module TraySize
  def self.call(barcode)
    /#{IsTrayBarcode.prefix}/.match(barcode)[2]
  end
end
