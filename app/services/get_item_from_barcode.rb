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
      item = Item.where(barcode: barcode).first_or_create!

      data = ApiGetItemMetadata.call(barcode)
      if data["status"] == 200
        item.attributes = data["results"]
        item.thickness ||= 0
        item.save!
      end
      item
    else
      raise "barcode is not an item"
    end
  end

  private

    def valid?
      IsItemBarcode.call(barcode)
    end
end
