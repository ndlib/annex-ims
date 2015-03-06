class Request < ActiveRecord::Base
  validates_presence_of :criteria_type
  validates_presence_of :criteria
  validates :rapid, :inclusion => {:in => [true, false]}
  validates_presence_of :source
  validates_presence_of :req_type

  belongs_to :batch
  belongs_to :item
end
