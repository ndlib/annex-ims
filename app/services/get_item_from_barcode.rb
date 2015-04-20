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
      item = Item.where(barcode: barcode).first_or_create!  # This section will need to throw things into a queue for background processing.

      data = ApiGetItemMetadata.call(barcode)
      if data["status"] == 200
        item.attributes = data["results"]
        item.thickness ||= 0
        item.save!
      elsif data["status"] == 404
        item.destroy!
        item = nil
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
