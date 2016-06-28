class TrayIssue < ActiveRecord::Base
  ISSUE_TYPES = ["incorrect_count", "not_valid_barcode"].freeze

  validates :barcode, presence: true
  validates :issue_type, presence: true, inclusion: ISSUE_TYPES

  belongs_to :user
  belongs_to :resolver, class_name: "User"
end
