module IsTrayBarcode
  PREFIX = "(TRAY-)(([A-E][H,L])|(#{IsShelfBarcode::PREFIX}))".freeze
  def self.call(barcode)
    (barcode =~ /^#{PREFIX}(.*)/ ) ? true : false
  end
end
