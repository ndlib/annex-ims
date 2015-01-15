class SearchItems
  attr_reader :filter

  def self.call(filter)
    new(filter).search!
  end

  def initialize(filter)
    @filter = filter
  end

  def search!
    results = Item.where(nil)

    if filter.has_key?(:criteria_type) && filter.has_key?(:criteria)
      case filter[:criteria_type]
      when "Barcode"
        results = results.where(barcode: filter[:criteria])
      when "Bib Number"
        results = results.where(bib_number: filter[:criteria])
      end
    end

# .where("'PAGES-DET' = ANY (conditions)")

    if results
      results
    else
      false
    end
  end

end
