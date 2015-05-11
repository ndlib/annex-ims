class Bin < ActiveRecord::Base
  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  validate :has_correct_prefix

  has_many :items, -> { order "updated_at DESC" }

  def has_correct_prefix
    if !IsBinBarcode.call(barcode)
      errors.add(:barcode, "must begin with #{IsBinBarcode::PREFIX}")
    end
  end
end
