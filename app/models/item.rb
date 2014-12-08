class Item < ActiveRecord::Base
  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  belongs_to :tray
end
