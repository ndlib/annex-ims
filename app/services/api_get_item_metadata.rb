class ApiGetItemMetadata
  API_PATH = "/1.0/resources/items/record"

  attr_reader :barcode

  def self.call(barcode)
    new(barcode).get_data!
  end

  def initialize(barcode)
    @barcode = barcode
  end

  def get_data!
    ApiHandler.get(API_PATH, { barcode: barcode })
  end
end
