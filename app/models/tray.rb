class Tray < ActiveRecord::Base
  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  validate :has_correct_prefix

  belongs_to :shelf
  has_many :items, -> { order "updated_at DESC" }

  def has_correct_prefix
    if !IsTrayBarcode.call(barcode)
      errors.add(:barcode, "must begin with #{IsTrayBarcode::PREFIX}")
    end
  end
end
