module IsShelfBarcode
  PREFIX = "SHELF-".freeze
  def self.call(barcode)
    /^#{PREFIX}(.*)/.match?(barcode) ? true : false
  end
end
