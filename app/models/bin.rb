class Bin < ActiveRecord::Base
  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  validate :has_correct_prefix

  has_many :items, -> { order "updated_at DESC" }
  has_many :matches, -> { order "updated_at DESC" }
  has_many :location_activity_logs, class_name: "ActivityLog", foreign_key: "location_bin_id"

  def has_correct_prefix
    if !IsBinBarcode.call(barcode)
      errors.add(:barcode, "must begin with #{IsBinBarcode::PREFIX}")
    end
  end
end
