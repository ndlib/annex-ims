class Shelf < ActiveRecord::Base
  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  validate :has_correct_prefix

  has_one :transfer
  has_many :trays
  has_many :items, through: :trays
  has_many :location_activity_logs, class_name: "ActivityLog", foreign_key: "location_shelf_id"

  def tray_type
    return nil if self.trays.count == 0
    return self.trays.first.tray_type
  end

  # following the questionable pattern from tray.rb
  def style
    result = case self.trays.count
      when 0 then 'black'
      when 1..(self.tray_type.trays_per_shelf - 1) then 'black'
      when self.tray_type.trays_per_shelf then 'red'
      else 'red'
    end
    result
  end

  def capacity
    tray_type.nil? ? 0 : tray_type.trays_per_shelf
  end

  def has_correct_prefix
    if !IsShelfBarcode.call(barcode)
      errors.add(:barcode, "must begin with #{IsShelfBarcode::PREFIX}")
    end
  end
end
