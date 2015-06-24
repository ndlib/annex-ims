class ApiGetItemMetadata
  attr_reader :barcode

  def self.call(barcode)
    new(barcode).get_data!
  end

  def initialize(barcode)
    @barcode = barcode
  end

  def get_data!
    validate_input!
    response
  end

  private

    def response
      response = ApiHandler.call("GET", "/1.0/resources/items/record", { barcode: barcode })
      ApiResponse.new(status_code: response.status_code, body: response_data(response.body))
    end

    def response_data(data = {})
      {
        title: data[:title],
        author: data[:author],
        chron: data[:description],
        bib_number: data[:bib_id],
        isbn_issn: data[:isbn_issn],
        conditions: data[:condition],
        call_number: data[:call_number],
      }
    end

    def validate_input!
      if IsItemBarcode.call(barcode)
        true
      else
        raise "barcode is not an item"
      end
    end

end
