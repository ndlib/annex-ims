class ApiGetItemMetadata
  attr_reader :barcode

  def self.call(barcode)
    new(barcode).get_data!
  end

  def initialize(barcode)
    @barcode = barcode
    @path = "/1.0/resources/items/record"
  end

  def get_data!
    validate_input!
    response
  end

  private

    def response
      raw_results = ApiHandler.call("GET", @path, { barcode: barcode })
      ApiResponse.new(status_code: raw_results["status"], body: response_data(raw_results["results"]))
    rescue Timeout::Error => e
      ApiResponse.new(status_code: 599, body: response_data())
    end

    def response_data(data = {})
      data = data.with_indifferent_access
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
