json.extract! report, :id, :name, :fields, :start_date, :end_date, :activity, :status, :created_at, :updated_at
json.url report_url(report, format: :json)
