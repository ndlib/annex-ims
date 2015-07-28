class Issue < ActiveRecord::Base
  ISSUE_TYPES = ["not_found", "not_for_annex", "aleph_error"]

  validates :barcode, presence: true
  validates :issue_type, presence: true, inclusion: ISSUE_TYPES
  validates :user_id, presence: true

  belongs_to :user
  belongs_to :resolver, class_name: "User"
end
