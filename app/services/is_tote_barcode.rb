class IsToteBarcode
  PREFIX = 'TOTE-'

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
