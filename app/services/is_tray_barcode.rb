module IsTrayBarcode
  def self.call(barcode)
    /^#{prefix}(.*)/.match?(barcode) ? true : false
  end

  def self.prefix
    codes = TrayType.where(active: true).pluck(:code)
    codes_str = codes.join(")|(")
    "(TRAY-)((#{codes_str}))"
  end
end
