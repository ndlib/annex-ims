module IsDeacBinBarcode
  PREFIX = "(BIN-)(DEAC-STOCK|DEAC-HAND)(-)".freeze
  def self.call(barcode)
    (barcode =~ /^#{PREFIX}(.*)/) ? true : false
  end
end
