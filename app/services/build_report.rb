class BuildReport
  attr_reader :fields, :start_date, :end_date, :activity, :status

  def self.call(fields, start_date, end_date, activity, status)
    new(fields, start_date, end_date, activity, status).build!
  end

  def initialize(fields, start_date, end_date, activity, status)
    @fields = fields
    @start_date = start_date
    @end_date = end_date
    @activity = activity
    @status = status
  end

  def build!
    sql = <<~SQL.gsub(/^[\s\t]*/, '').gsub(/[\s\t]*\n/, ' ').strip
      SELECT
        b.created_at AS "requested",
        p.created_at AS "pull",
        a.created_at AS "filled",
        a.data->'request'->'source' AS "source",
        a.data->'request'->'req_type' AS "request_type",
        a.data->'request'->'del_type' AS "del",
        a.data->'request'->'patron_status' AS "patron_status",
        a.data->'request'->'patron_institution' AS "institution",
        a.data->'request'->'patron_department' AS "department",
        a.data->'request'->'pickup_location' AS "pickup_location",
        TRIM(SUBSTR(i.call_number,1,2)) AS "class"
      FROM activity_logs a
        LEFT JOIN items i ON CAST(a.data->'request'->>'item_id' AS INTEGER) = i.id
        LEFT JOIN activity_logs b ON CAST(a.data->'request'->>'id' AS INTEGER) = CAST(b.data->'request'->>'id' AS INTEGER) AND b.action = 'ReceivedRequest'
        LEFT JOIN activity_logs p ON CAST(a.data->'request'->>'item_id' AS INTEGER) = CAST(p.data->'item'->>'id' AS INTEGER) AND p.action = 'AssociatedItemAndBin' AND p.created_at BETWEEN b.created_at AND a.created_at
      WHERE a.action = 'FilledRequest'
        AND p.created_at BETWEEN '#{@start_date}' AND '#{@end_date}'
      ORDER BY
        p.created_at,
        b.created_at,
        a.created_at
    SQL

    results = ActiveRecord::Base.connection.execute(sql).to_a
  end
end
