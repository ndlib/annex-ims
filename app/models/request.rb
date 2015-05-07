class Request < ActiveRecord::Base
  validates_presence_of :criteria_type
  validates_presence_of :criteria
  validates :rapid, :inclusion => {:in => [true, false]}
  validates_presence_of :source
  validates_presence_of :req_type

  has_many :matches
  has_many :items, through: :matches
  has_many :batches, through: :matches
end
