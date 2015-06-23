class IsBinBarcode
  PREFIX = '(BIN-)(ILL-LOAN|ILL-SCAN|ALEPH-LOAN)(-)'

  attr_reader :barcode

  def self.call(barcode)
    new(barcode).compare
  end

  def initialize(barcode)
    @barcode = barcode
  end

  def compare
    (barcode =~ /^#{PREFIX}(.*)/ ) ? true : false
  end

end
