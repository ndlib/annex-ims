class Shelf < ActiveRecord::Base
  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  validate :has_correct_prefix

  has_many :trays
  has_many :items, through: :trays

  def has_correct_prefix
    if !IsShelfBarcode.call(barcode)
      errors.add(:barcode, "must begin with #{IsShelfBarcode::PREFIX}")
    end
  end
end
