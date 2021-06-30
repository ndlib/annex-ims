# frozen_string_literal: true

class BuildReport
  attr_reader :fields,
              :start_date,
              :end_date,
              :preset_date_range,
              :activity,
              :request_status,
              :item_status,
              :selects,
              :joins,
              :from,
              :where_conditions,
              :where_values,
              :orders

  ITEM_ACTIVITES = %w[
    AcceptedItem
    ApiDeaccessionItem
    ApiScanItem
    ApiSendItem
    ApiStockItem
    AssociatedItemAndBin
    AssociatedItemandTray
    CreatedIssue
    CreatedItem
    DeaccessionedItem
    DestroyedItem
    DissociatedItemAndTray
    MatchedItem
    RemovedMatch
    ScannedItem
    SetItemDisposition
    ShippedItem
    SkippedItem
    StockedItem
    UnstockedItem
    UpdatedBarcode
    UpdatedItemMetadata
  ].freeze

  BASE_SELECT = ["Date_trunc('minute', a.created_at) AS \"activity\""].freeze
  BASE_WHERE_CONDITIONS = ['a.action = :activity'].freeze
  BASE_ORDERS = ["Date_trunc('minute', a.created_at)"].freeze

  def self.call(fields, start_date, end_date, preset_date_range, activity, request_status, item_status)
    new(fields, start_date, end_date, preset_date_range, activity, request_status, item_status).build!
  end

  def initialize(fields, start_date, end_date, preset_date_range, activity, request_status, item_status)
    @fields = fields
    @start_date = start_date
    @end_date = end_date
    @preset_date_range = preset_date_range
    @activity = activity
    @request_status = request_status
    @item_status = item_status

    @tables_available = ActivityLog::ACTION_TABLES[@activity]
    @tables_needed = []

    @selects = BASE_SELECT.dup
    @joins = []
    @from = 'activity_logs a'
    @where_conditions = BASE_WHERE_CONDITIONS.dup
    @where_values = { activity: @activity }
    @wheres = []
    @orders = BASE_ORDERS.dup
  end

  def build!
    sql = to_sql
    results = ActiveRecord::Base.connection.execute(sql).to_a

    {
      results: results,
      sql: sql
    }
  end

  def to_sql
    fields.each do |field|
      send("handle_#{field}".to_sym)
    end

    handle_request_status if @request_status.present?
    handle_item_status if @item_status.present?

    add_joins

    # this one has no tables to join to, so just clear everything out or the query will break
    if @activity == 'ApiGetRequestList'
      @selects = BASE_SELECT.dup
      @joins = []
      @where_conditions = BASE_WHERE_CONDITIONS.dup
      @where_values = { activity: @activity }
      @orders = BASE_ORDERS.dup
    end

    handle_preset_date_range if @preset_date_range.present?

    handle_start_date if @start_date.present?
    handle_end_date if @end_date.present?

    @wheres = [@where_conditions.uniq.join(' and '), @where_values]

    sql = ActivityLog.select(@selects.uniq).from(@from).joins(@joins.uniq).where(@wheres).distinct.order(@orders.uniq).to_sql

    sql
  end

  private

  def handle_requested
    @tables_needed << 'requests'

    @selects.append("Date_trunc('minute', b.created_at) AS \"requested\"")

    @joins.append("LEFT JOIN activity_logs b ON r.id = CAST(b.data->'request'->>'id' AS INTEGER) AND b.action = 'ReceivedRequest'")

    @orders.append("Date_trunc('minute', b.created_at)")
  end

  def handle_pulled
    @tables_needed << 'items'
    @tables_needed << 'requests'

    @selects.append("Date_trunc('minute', p.created_at) AS \"pulled\"")

    @joins.append("LEFT JOIN activity_logs b ON r.id = CAST(b.data->'request'->>'id' AS INTEGER) AND b.action = 'ReceivedRequest'")
    @joins.append("LEFT JOIN activity_logs p ON i.id = CAST(p.data->'item'->>'id' AS INTEGER) AND p.action = 'AssociatedItemAndBin' AND p.created_at BETWEEN b.created_at AND a.created_at")

    @orders.append("Date_trunc('minute', p.created_at)")
  end

  def handle_filled
    @tables_needed << 'requests'

    @selects.append("Date_trunc('minute', f.created_at) AS \"filled\"")

    @joins.append("LEFT JOIN activity_logs f ON r.id = CAST(f.data->'request'->>'id' AS INTEGER) AND f.action = 'FilledRequest'")

    @orders.append("Date_trunc('minute', f.created_at)")
  end

  def handle_source
    @tables_needed << 'requests'

    @selects.append('r.source AS "source"')
  end

  def handle_request_type
    @tables_needed << 'requests'

    @selects.append('r.req_type AS "request_type"')
  end

  def handle_patron_status
    @tables_needed << 'requests'

    @selects.append('r.patron_status AS "patron_status"')
  end

  def handle_institution
    @tables_needed << 'requests'

    @selects.append('r.patron_institution AS "institution"')
  end

  def handle_department
    @tables_needed << 'requests'

    @selects.append('r.patron_department AS "department"')
  end

  def handle_pickup_location
    @tables_needed << 'requests'

    @selects.append('r.pickup_location AS "pickup_location"')
  end

  def handle_class
    @tables_needed << 'items'

    @selects.append('TRIM(SUBSTR(i.call_number,1,2)) AS "class"')
  end

  def handle_time_to_pull
    handle_requested
    handle_pulled

    @selects.append("age(Date_trunc('minute', p.created_at), Date_trunc('minute', b.created_at)) AS \"time_to_pull\"")
  end

  def handle_time_to_fill
    handle_requested
    handle_filled

    @selects.append("age(Date_trunc('minute', f.created_at), Date_trunc('minute', b.created_at)) AS \"time_to_fill\"")
  end

  def handle_start_date
    @where_conditions.append('a.created_at >= :start_date')

    @where_values[:start_date] = @start_date
  end

  def handle_end_date
    @where_conditions.append('a.created_at <= :end_date')

    @where_values[:end_date] = @end_date
  end

  def handle_request_status
    if @tables_available.include?('requests')

      @where_conditions.append("a.data->'request'->>'status' = :request_status")

      @where_values[:request_status] = Request::STATUSES[@request_status]
    else
      @tables_needed << 'requests'

      @where_conditions.append('r.status = :request_status')

      @where_values[:request_status] = @request_status.to_i
    end
  end

  def handle_item_status
    @tables_needed << 'items'

    @where_conditions.append('i.status = :item_status')

    @where_values[:item_status] = @item_status.to_i
  end

  def handle_preset_date_range
    case @preset_date_range
    when 'current_day'
      @start_date = Time.zone.today.beginning_of_day
      @end_date = Time.zone.today.end_of_day
    when 'previous_day'
      @start_date = Time.zone.yesterday.beginning_of_day
      @end_date = Time.zone.yesterday.end_of_day
    when 'current_week'
      @start_date = Time.zone.today.beginning_of_week(start_day = :monday).beginning_of_day
      @end_date = Time.zone.today.end_of_day
    when 'previous_week'
      @start_date = Time.zone.today.beginning_of_week(start_day = :monday).last_week.beginning_of_day
      @end_date = (Time.zone.today.beginning_of_week(start_day = :monday).last_week + 6).end_of_day
    when 'current_month'
      @start_date = Time.zone.today.beginning_of_month.beginning_of_day
      @end_date = Time.zone.today.end_of_day
    when 'previous_month'
      @start_date = 1.month.ago.beginning_of_month.beginning_of_day
      @end_date = 1.month.ago.end_of_month.end_of_day
    when 'current_year'
      @start_date = Time.zone.today.beginning_of_year.beginning_of_day
      @end_date = Time.zone.today.end_of_day
    when 'current_fiscal_year'
      start = Time.zone.today
      start = start.change(year: start.year - 1) if start.month < 7
      start = start.change(month: 7).beginning_of_month
      @start_date = start.beginning_of_day
      @end_date = Time.zone.today.end_of_day
    end
  end

  def add_joins
    if @tables_needed.include?('items')
      @selects << 'i.id AS "item_id"'

      if @tables_available.include?('items')
        @joins.prepend("LEFT JOIN items i ON Cast(a.data -> 'item' ->> 'id' AS INTEGER) = i.id ")
      elsif @tables_available.include?('requests')
        @joins.prepend('LEFT JOIN items i ON r.item_id = i.id')
        @joins.prepend("LEFT JOIN requests r ON Cast(a.data -> 'request' ->> 'id' AS INTEGER) = r.id ")
      elsif @tables_available.include?('trays')
        @joins.prepend('LEFT JOIN items i ON t.id = i.tray_id')
        @joins.prepend("LEFT JOIN trays t ON Cast(a.data -> 'tray' ->> 'id' AS INTEGER) = t.id")
      elsif @tables_available.include?('shelves')
        @joins.prepend('LEFT JOIN items i ON t.id = i.tray_id')
        @joins.prepend('LEFT JOIN trays t ON s.id = t.shelf_id')
        @joins.prepend("LEFT JOIN shelves s ON Cast(a.data -> 'shelf' ->> 'id' AS INTEGER) = s.id")
      end
    end

    if @tables_needed.include?('requests')
      @selects << 'r.id AS "request_id"'

      if @tables_available.include?('requests')
        @joins.prepend("LEFT JOIN requests r ON Cast(a.data -> 'request' ->> 'id' AS INTEGER) = r.id ")
      elsif @tables_available.include?('items')
        @joins.prepend('LEFT JOIN requests r ON i.id = r.item_id')
        @joins.prepend("LEFT JOIN items i ON Cast(a.data -> 'item' ->> 'id' AS INTEGER) = i.id ")
      elsif @tables_available.include?('trays')
        @joins.prepend('LEFT JOIN requests r ON i.id = r.item_id')
        @joins.prepend('LEFT JOIN items i ON t.id = i.tray_id')
        @joins.prepend("LEFT JOIN trays t ON Cast(a.data -> 'tray' ->> 'id' AS INTEGER) = t.id")
      elsif @tables_available.include?('shelves')
        @joins.prepend('LEFT JOIN requests r ON i.id = r.item_id')
        @joins.prepend('LEFT JOIN items i ON t.id = i.tray_id')
        @joins.prepend('LEFT JOIN trays t ON s.id = t.shelf_id')
        @joins.prepend("LEFT JOIN shelves s ON Cast(a.data -> 'shelf' ->> 'id' AS INTEGER) = s.id")
      end
    end
  end
end
