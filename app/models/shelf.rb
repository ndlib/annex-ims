class Shelf < ActiveRecord::Base
  require 'barcode_prefix'
  include BarcodePrefix

  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  validate :has_correct_prefix

  has_many :trays

  def has_correct_prefix
    if !is_shelf(barcode)
      errors.add(:barcode, "must begin with #{SHELF_PREFIX}")
    end
  end
end
