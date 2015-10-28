class Transfer < ActiveRecord::Base
  belongs_to :shelf
  belongs_to :initiated_by, class_name: "User"

  validates_presence_of :shelf
  validates_presence_of :initiated_by
  validates_presence_of :transfer_type
end
