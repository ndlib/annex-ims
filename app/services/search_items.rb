class SearchItems
  CRITERIA_TYPES = [
    %w(Search All Fields any),
    %w(Barcode barcode),
    %w(Bib Number bib_number),
    %w(Call Number call_number),
    %w(ISBN/ISSN isbn_issn),
    %w(Title title),
    %w(Author author),
    %w(Tray tray),
    %w(Shelf shelf)
  ].freeze

  DEFAULT_PER_PAGE = 50 # We could customize this, but let's stick with 50 for now.

  attr_reader :filter

  def self.call(filter)
    new(filter).search!
  end

  def initialize(filter)
    @filter = filter
  end

  def page
    fetch(:page).present? ? fetch(:page) : 1
  end

  def per_page
    fetch(:per_page) || DEFAULT_PER_PAGE
  end

  def conditions
    fetch(:conditions).keys if filter?(:conditions)
  end

  def search!
    (search_fulltext? || search_conditions? || search_date?) ? search_results : empty_results
  end

  private

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  def search_results
    Item.search do
      without(:status, "deaccessioned")

      paginate page: page, per_page: per_page

      if search_fulltext?
        # remove the special character '-' because they screw with isbn queries
        # we may also want to consider removing other special chars eg. *,+,"
        criteria = fetch(:criteria).gsub(/[\-\.]/, "")
        fulltext(criteria, fields: fulltext_fields) do
          minimum_match "75%"
        end
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
    @date_start ||= filter?(:start) ? Date.parse(fetch(:start)) : nil
  end

  def date_finish
    @date_finish ||= filter?(:finish) ? Date.parse(fetch(:finish)) : nil
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
      @search_fulltext ||= filter?(:criteria_type) && filter?(:criteria) && fulltext_fields.present?
    end
    @search_fulltext
  end

  def search_conditions?
    filter?(:conditions) && filter?(:condition_bool)
  end

  def search_date?
    filter?(:date_type) && (filter?(:start) || filter?(:finish)) && date_field.present?
  end

  def fulltext_fields
    @fulltext_fields ||= fulltext_field_to_symbol
  end

  def fulltext_field_to_symbol
    if fetch(:criteria_type) == "any"
      [:barcode, :bib_number, :call_number, :isbn_issn, :title, :author, :tray_barcode, :shelf_barcode]
    elsif fetch(:criteria_type) == "tray"
      :tray_barcode
    elsif fetch(:criteria_type) == "shelf"
      :shelf_barcode
    else
      fetch(:criteria_type).to_sym
    end
  end

  def empty_results
    EmptyResults.new
  end

  def filter?(key)
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
