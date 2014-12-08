class Shelf < ActiveRecord::Base
  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  has_many :trays
end
