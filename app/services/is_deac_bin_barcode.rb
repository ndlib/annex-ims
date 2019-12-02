module IsDeacBinBarcode
  PREFIX = "(BIN-)(REM-STOCK|REM-HAND)(-)".freeze
  def self.call(barcode)
    /^#{PREFIX}(.*)/.match?(barcode) ? true : false
  end
end
