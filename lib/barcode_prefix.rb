module BarcodePrefix
  TRAY_PREFIX = 'TRAY-'
  SHELF_PREFIX = 'SHELF-'
  TOTE_PREFIX = 'TOTE-'

  def is_tray(barcode)
    (barcode =~ /^#{TRAY_PREFIX}(.*)/ ) ? true : false
  end

  def is_shelf(barcode)
    (barcode =~ /^#{SHELF_PREFIX}(.*)/ ) ? true : false
  end

  def is_item(barcode)
    (barcode =~ /[0-9]/ ) ? true : false
  end

  def is_tote(barcode)
    (barcode =~ /^#{TOTE_PREFIX}(.*)/ ) ? true : false
  end

end
