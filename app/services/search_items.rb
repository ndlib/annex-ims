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
    if search_fulltext? || search_conditions? || search_date?
      search_results
    else
      empty_results
    end
  end

  private

  def search_results # rubocop:disable Metrics/AbcSize
    Item.search do
      paginate page: page, per_page: per_page

      if search_fulltext?
        criteria = exact_match? ? fetch(:criteria) : "*#{fetch(:criteria)}*"
        fulltext(criteria, fields: fulltext_fields)
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

      if search_date?
        any_of do
          if date_start && date_finish
            with(date_field, date_start..date_finish)
          elsif date_start
            with(date_field).greater_than_or_equal_to(date_start)
          elsif date_finish
            with(date_field).less_than_or_equal_to(date_finish)
          end
        end
      end

      order_by(:chron, :asc)
    end
  end

  def date_start
    @date_start ||= has_filter?(:start) ? Date.parse(fetch(:start)) : nil
  end

  def date_finish
    @date_finish ||= has_filter?(:finish) ? Date.parse(fetch(:finish)) : nil
  end

  def date_field
    case fetch(:date_type)
    when "request"
      :requested
    when "initial"
      :initial_ingest
    when "last"
      :last_ingest
    end
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

  def exact_match?
    false || (has_filter?(:exact_match) && fetch(:exact_match))
  end

  def search_date?
    has_filter?(:date_type) && (has_filter?(:start) || has_filter?(:finish)) && date_field.present?
  end

  def fulltext_fields
    @fulltext_fields ||= get_fulltext_fields
  end

  def get_fulltext_fields
    case fetch(:criteria_type)
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
