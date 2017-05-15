class Disposition < ActiveRecord::Base
  validates_presence_of :code
  validates :code, uniqueness: true
  validates_inclusion_of :active, :in => [true, false]
  has_many :requests
end
