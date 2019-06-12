module IsTrayBarcode
  def self.call(barcode)
    (barcode =~ /^#{self.prefix}(.*)/ ) ? true : false
  end

  def self.prefix
    codes = TrayType.where(active: true).pluck(:code)
    codes_str = codes.join(")|(")
    return "(TRAY-)((#{codes_str}))"
  end
end
