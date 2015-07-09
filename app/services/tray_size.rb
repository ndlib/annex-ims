module TraySize
  def self.call(barcode)
    /#{IsTrayBarcode::PREFIX}/.match(barcode)[2]
  end
end
