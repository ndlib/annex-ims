class Tray < ActiveRecord::Base
  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  validate :has_correct_prefix

  belongs_to :shelf
  has_many :items, -> { order "updated_at DESC" }
  has_many :activity_logs, class_name: "ActivityLog", foreign_key: "object_tray_id"
  has_many :location_activity_logs, class_name: "ActivityLog", foreign_key: "location_tray_id"

  def has_correct_prefix
    if !IsTrayBarcode.call(barcode)
      errors.add(:barcode, "must begin with #{IsTrayBarcode::PREFIX}")
    end
  end
end
