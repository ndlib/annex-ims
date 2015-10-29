class Transfer < ActiveRecord::Base
  belongs_to :shelf
  belongs_to :initiated_by, class_name: "User"

  validates :shelf, :initiated_by, :transfer_type, presence: true
end
