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

    params = "barcode=#{@barcode}"
    raw_results = ApiHandler.call("GET", @path, params)

    results = {"status" => raw_results["status"], "results" => 
      {
        "title" => raw_results["results"]["title"],
        "author" => raw_results["results"]["author"],
        "chron" => raw_results["results"]["description"],
        "bib_number" => raw_results["results"]["bib_id"],
        "isbn_issn" => raw_results["results"]["isbn_issn"],
        "conditions" => raw_results["results"]["condition"],
        "call_number" => raw_results["results"]["call_number"]
      }}

     results
  end

  private

    def validate_input!
      if IsItemBarcode.call(barcode)
        true
      else
        raise "barcode is not an item"
      end
    end

end
