class Item < ActiveRecord::Base
  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  validates :barcode, numericality: { only_integer: true }

  belongs_to :tray
end
