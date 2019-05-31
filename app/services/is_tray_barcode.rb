module IsTrayBarcode
  codes = TrayType.pluck(:code)
  codes_str = codes.join(")|(")
  PREFIX = "(TRAY-)((#{codes_str}))"
  def self.call(barcode)
    (barcode =~ /^#{PREFIX}(.*)/ ) ? true : false
  end
end
