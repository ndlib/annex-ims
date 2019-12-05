module IsBinBarcode
  PREFIX = "(BIN-)(ILL-LOAN|ILL-SCAN|ALEPH-LOAN|REM-STOCK|REM-HAND)(-)".freeze
  def self.call(barcode)
    /^#{PREFIX}(.*)/.match?(barcode) ? true : false
  end
end
