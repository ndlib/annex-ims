class GetTrayFromBarcode
  attr_reader :barcode

  def self.call(barcode)
    new(barcode).get
  end

  def initialize(barcode)
    @barcode = barcode
  end

  def get
    if valid?
      Tray.where(barcode: barcode).first_or_create!
    else
      raise "barcode is not a tray"
    end
  end

  private

    def valid?
      IsTrayBarcode.call(barcode)
    end
end
