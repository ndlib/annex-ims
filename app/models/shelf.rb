class Shelf < ActiveRecord::Base
  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  validate :has_correct_prefix

  has_one :transfer
  has_many :trays
  has_many :items, through: :trays
  has_many :location_activity_logs, class_name: "ActivityLog", foreign_key: "location_shelf_id"

  def has_correct_prefix
    if !IsShelfBarcode.call(barcode)
      errors.add(:barcode, "must begin with #{IsShelfBarcode::PREFIX}")
    end
  end
end
