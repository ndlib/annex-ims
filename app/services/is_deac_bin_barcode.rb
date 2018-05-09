module IsDeacBinBarcode
  PREFIX = "(BIN-)(REM-STOCK|REM-HAND)(-)".freeze
  def self.call(barcode)
    (barcode =~ /^#{PREFIX}(.*)/) ? true : false
  end
end
