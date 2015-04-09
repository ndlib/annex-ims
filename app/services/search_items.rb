class SearchItems
  CRITERIA_TYPES = [["Search All Fields", "any"],
    ["Barcode", "barcode"],
    ["Bib Number", "bib_number"],
    ["Call Number", "call_number"],
    ["ISBN/ISSN", "isbn_issn"],
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
      count = Item.count
      results = Item.search do
        paginate :page => 1, :per_page => count
        if filter.has_key?(:criteria_type) && filter.has_key?(:criteria)
            case filter[:criteria_type]
            when "ERROR"
              fulltext("ERROR", :fields => :tray_barcode) # should return no results
            when "any"
              fulltext(filter[:criteria], :fields => [:barcode, :bib_number, :call_number, :isbn_issn, :title, :author, :tray_barcode, :shelf_barcode])
            when "barcode"
              fulltext(filter[:criteria], :fields => :barcode)
            when "bib_number"
              fulltext(filter[:criteria], :fields => :bib_number)
            when "call_number"
              fulltext(filter[:criteria], :fields => :call_number)
            when "isbn_issn"
              fulltext(filter[:criteria], :fields => :isbn_issn)
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
          elsif filter.has_key?(:condition_bool) && filter[:condition_bool] == "any"
            any_of do
              with(:conditions, filter[:conditions].keys)
            end
          elsif filter.has_key?(:condition_bool) && filter[:condition_bool] == "none"
            all_of do
              filter[:conditions].keys.each do |condition|
                without(:conditions, condition)
              end
            end
          end
        end

        if filter.has_key?(:date_type)
          filter[:start] ||= "2015-01-01"   # I needed a reasonable date before which there would be no requests or ingests. Can adjust if needed.
          filter[:finish] ||= Date::today.to_s # Seems unlikely that we'll have any requests or ingests in the future.
          case filter[:date_type]
            when "request"
              any_of do
                with(:requested, Date.parse(filter[:start])..Date.parse(filter[:finish]))
              end
            when "initial"
              with(:initial_ingest, Date.parse(filter[:start])..Date.parse(filter[:finish]))
            when "last"
              with(:last_ingest, Date.parse(filter[:start])..Date.parse(filter[:finish]))
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
