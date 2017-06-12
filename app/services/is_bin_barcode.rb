module IsBinBarcode
  PREFIX = "(BIN-)(ILL-LOAN|ILL-SCAN|ALEPH-LOAN|DEAC-STOCK|DEAC-HAND)(-)".freeze
  def self.call(barcode)
    (barcode =~ /^#{PREFIX}(.*)/) ? true : false
  end
end
