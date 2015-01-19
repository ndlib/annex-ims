class SearchItems
  CRITERIA_TYPES = [["Barcode", "barcode"],
    ["Bib Number", "bib_number"],
    ["Call Number", "call_number"],
    ["ISBN", "isbn"],
    ["ISSN", "issn"],
    ["Title", "title"],
    ["Author", "author"],
    ["Tray", "tray"],
    ["Shelf", "shelf"]]

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
      when "barcode"
        results = results.where(barcode: filter[:criteria])
      when "bib_number"
        results = results.where(bib_number: filter[:criteria])
      when "call_number"
        results = results.where(call_number: filter[:criteria])
      when "isbn"
        results = results.where(isbn: filter[:criteria])
      when "issn"
        results = results.where(issn: filter[:criteria])
      when "title"
        results = results.where(title: filter[:criteria])
      when "author"
        results = results.where(author: filter[:criteria])
      when "tray"
        results = results.joins(:tray).where(trays: {barcode: filter[:criteria]})
      when "shelf"
        results = results.joins(tray: :shelf).where(shelves: {barcode: filter[:criteria]})
      end
    end

    if filter.has_key?(:conditions)
      if filter.has_key?(:condition_bool) && filter[:condition_bool] == "all"
        results = results.where("conditions @> ARRAY[?]", filter[:conditions].keys)
      else
        results = results.where("conditions && ARRAY[?]", filter[:conditions].keys)
      end
    end

    if filter.has_key?(:date_type)
      filter[:start] ||= "2015-01-01"   # I needed a reasonable date before which there would be no requests or ingests. Can adjust if needed.
      filter[:end] ||= Date::today.to_s # Seems unlikely that we'll have any requests or ingests in the future.
      case filter[:date_type]
      when "request"
        results = results
      when "initial"
        results = results.where(:initial_ingest => filter[:start]..filter[:finish])
      when "last"
        results = results.where(:last_ingest => filter[:start]..filter[:finish])
      end
    end

    if results
      results
    else
      false
    end
  end

end
