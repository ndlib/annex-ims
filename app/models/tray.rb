class Tray < ActiveRecord::Base
  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  belongs_to :shelf
  has_many :items
end
