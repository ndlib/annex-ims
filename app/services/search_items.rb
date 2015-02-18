class SearchItems
  CRITERIA_TYPES = [["Search All Fields", "any"],
    ["Barcode", "barcode"],
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

    if filter[:criteria].blank? && filter[:conditions].blank? && filter[:date_type].blank?
      results = []
    else
      results = Item.search do
        if filter.has_key?(:criteria_type) && filter.has_key?(:criteria)
            case filter[:criteria_type]
            when "any"
              fulltext(filter[:criteria], :fields => [:barcode, :bib_number, :call_number, :isbn, :issn, :title, :author, :tray_barcode, :shelf_barcode])
            when "barcode"
              fulltext(filter[:criteria], :fields => :barcode)
            when "bib_number"
              fulltext(filter[:criteria], :fields => :bib_number)
            when "call_number"
              fulltext(filter[:criteria], :fields => :call_number)
            when "isbn"
              fulltext(filter[:criteria], :fields => :isbn)
            when "issn"
              fulltext(filter[:criteria], :fields => :issn)
            when "title"
              fulltext(filter[:criteria], :fields => :title)
            when "author"
              fulltext(filter[:criteria], :fields => :author)
            when "tray"
              fulltext(filter[:criteria], :fields => :tray_barcode)
            when "shelf"
              fulltext(filter[:criteria], :fields => :shelf_barcode)
          end
        end

        if filter.has_key?(:conditions)
          if filter.has_key?(:condition_bool) && filter[:condition_bool] == "all"
            all_of do
              filter[:conditions].keys.each do |condition|
                with(:conditions, condition)
              end
            end
          else
            any_of do
              with(:conditions, filter[:conditions].keys)
            end
          end
        end

        if filter.has_key?(:date_type)
          filter[:start] ||= "2015-01-01"   # I needed a reasonable date before which there would be no requests or ingests. Can adjust if needed.
          filter[:end] ||= Date::today.to_s # Seems unlikely that we'll have any requests or ingests in the future.
          case filter[:date_type]
            when "request"
              any_of do
                with(:requested, filter[:start]..filter[:finish])
              end
            when "initial"
              with(:initial_ingest, filter[:start]..filter[:finish])
            when "last"
              with(:last_ingest, filter[:start]..filter[:finish])
          end
        end

      end

      if results
        results.results
      else
        []
      end

    end

  end

end
