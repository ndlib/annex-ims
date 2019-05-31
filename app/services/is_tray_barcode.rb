module IsTrayBarcode
  codes = TrayType.pluck(:code)
  codes_str = codes.join(")|(")
  PREFIX = "(TRAY-)((#{codes_str}))".freeze
  def self.call(barcode)
    (barcode =~ /^#{PREFIX}(.*)/ ) ? true : false
  end
end
