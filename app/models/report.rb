# frozen_string_literal: true

class Report < ApplicationRecord
  serialize :fields

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :activity,
            presence: true,
            inclusion: ActivityLog::ACTIONS

  before_save :constrain_fields

  FIELDS = {
    'requested' => 'Requested',
    'filled' => 'Filled',
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
    p BuildReport.call(fields, start_date, end_date, activity, status)
  end

  def constrain_fields
    self.fields = fields.&(Report::FIELDS.keys)
  end
end
