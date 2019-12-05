class GetBinFromBarcode
  attr_reader :barcode

  def self.call(barcode)
    new(barcode).get
  end

  def initialize(barcode)
    @barcode = barcode
  end

  def get
    if valid?
      Bin.where(barcode: barcode).first_or_create!
    else
      raise "barcode is not a bin"
    end
  end

  private

  def valid?
    IsBinBarcode.call(barcode)
  end
end
