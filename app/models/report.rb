# frozen_string_literal: true

class Report < ApplicationRecord
  serialize :fields

  validates :name, presence: true
  validates :activity,
            presence: true,
            inclusion: ActivityLog::ACTIONS
  validates :request_status,
            inclusion: Request::STATUSES.keys,
            allow_blank: true
  validates :item_status,
            inclusion: Item::STATUSES.keys,
            allow_blank: true

  before_save :constrain_fields

  FIELDS = {
    'requested' => 'Requested',
    'filled' => 'Filled',
    'pulled' => 'Pulled',
    'source' => 'Source',
    'request_type' => 'Request Type',
    'patron_status' => 'Patron Status',
    'institution' => 'Institution',
    'department' => 'Department',
    'pickup_location' => 'Pickup Location',
    'class' => 'Class',
    'time_to_pull' => 'Time to Pull',
    'time_to_fill' => 'Time to Fill'
  }.freeze

  def run
    BuildReport.call(fields, start_date, end_date, activity, request_status, item_status)
  end

  def constrain_fields
    self.fields = fields.&(Report::FIELDS.keys)
  end
end
