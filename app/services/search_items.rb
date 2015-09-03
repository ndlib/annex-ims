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

  DEFAULT_PER_PAGE = 50 # We could customize this, but let's stick with 50 for now.
  DEFAULT_START_DATE = "2015-01-01" # I needed a reasonable date before which there would be no requests or ingests. Can adjust if needed.

  attr_reader :filter

  def self.call(filter)
    new(filter).search!
  end

  def initialize(filter)
    @filter = filter
  end

  def page
    requested_page = fetch(:page)
    if requested_page.present?
      requested_page
    else
      1
    end
  end

  def per_page
    fetch(:per_page) || DEFAULT_PER_PAGE
  end

  def conditions
    if has_filter?(:conditions)
      fetch(:conditions).keys
    end
  end

  def search!
    if search_fulltext? || has_filter?(:conditions) || has_filter?(:date_type)
      search_results
    else
      empty_results
    end
  end

  private

  def search_results
    Item.search do
      paginate page: page, per_page: per_page

      if search_fulltext?
        fulltext(fetch(:criteria), fields: fulltext_fields)
      end

      if search_conditions?
        case fetch(:condition_bool)
        when "all"
          all_of do
            conditions.each do |condition|
              with(:conditions, condition)
            end
          end
        when "any"
          any_of do
            with(:conditions, conditions)
          end
        when "none"
          all_of do
            conditions.each do |condition|
              without(:conditions, condition)
            end
          end
        end
      end

      if has_filter?(:date_type)
        range = date_start..date_finish
        case filter[:date_type]
        when "request"
          any_of do
            with(:requested, range)
          end
        when "initial"
          with(:initial_ingest, range)
        when "last"
          with(:last_ingest, range)
        end
      end

      order_by(:chron, :asc)
    end
  end

  def date_start
    @date_start ||= Date.parse(filter_start)
  end

  def date_finish
    @date_finish ||= Date.parse(filter_finish)
  end

  def filter_start
    @filter_start ||= has_filter?(:start) ? fetch(:start) : DEFAULT_START_DATE
  end

  def filter_finish
    @filter_finish ||= has_filter?(:finish) ? fetch(:finish) : Date::today.to_s
  end

  def search_fulltext?
    if @search_fulltext.nil?
      @search_fulltext ||= has_filter?(:criteria_type) && has_filter?(:criteria) && fulltext_fields.present?
    end
    @search_fulltext
  end

  def search_conditions?
    has_filter?(:conditions) && has_filter?(:condition_bool)
  end

  def fulltext_fields
    @fulltext_fields ||= case fetch(:criteria_type)
    when "any"
      [:barcode, :bib_number, :call_number, :isbn_issn, :title, :author, :tray_barcode, :shelf_barcode]
    when "barcode"
      :barcode
    when "bib_number"
      :bib_number
    when "call_number"
      :call_number
    when "isbn_issn"
      :isbn_issn
    when "title"
      :title
    when "author"
      :author
    when "tray"
      :tray_barcode
    when "shelf"
      :shelf_barcode
    end
  end

  def empty_results
    EmptyResults.new
  end

  def has_filter?(key)
    fetch(key).present?
  end

  def fetch(key)
    filter.fetch(key, nil)
  end

  class EmptyResults
    def results
      []
    end

    def total
      0
    end
  end

end
