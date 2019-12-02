class GetShelfFromBarcode
  attr_reader :barcode

  def self.call(barcode)
    new(barcode).get
  end

  def initialize(barcode)
    @barcode = barcode
  end

  def get
    if valid?
      Shelf.where(barcode: barcode).first_or_create!
    else
      raise "barcode is not a shelf"
    end
  end

  private

  def valid?
    IsShelfBarcode.call(barcode)
  end
end
