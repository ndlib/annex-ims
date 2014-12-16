class GetItemFromBarcode
  attr_reader :barcode

  def self.call(barcode)
    new(barcode).get
  end

  def initialize(barcode)
    @barcode = barcode
  end

  def get
    if valid?
      Item.where(barcode: barcode).first
    else
      raise "barcode is not an item"
    end
  end

  private

    def valid?
      IsItemBarcode.call(barcode)
    end
end
