module IsShelfBarcode
  PREFIX = "SHELF-".freeze
  def self.call(barcode)
    (barcode =~ /^#{PREFIX}(.*)/ ) ? true : false
  end
end
