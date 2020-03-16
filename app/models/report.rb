class Report < ApplicationRecord
  serialize :fields

  FIELDS = {
    requested: "Requested",
    filled: "Filled",
    source: "Source",
    request_type: "Request Type",
    patron_status: "Patron Status",
    institution: "Institution",
    department: "Department",
    pickup_location: "Pickup Location",
    class: "Class",
    time_to_pull: "Time to Pull",
    time_to_fill: "Time to Fill"
  }

  def run
    p BuildReport.call(fields, start_date, end_date, activity, status)
  end
end
