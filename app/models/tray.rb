class Tray < ActiveRecord::Base
  require 'barcode_prefix'
  include BarcodePrefix

  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  validate :has_correct_prefix

  belongs_to :shelf
  has_many :items

  def has_correct_prefix
    if !is_tray(barcode)
      errors.add(:barcode, "must begin with #{TRAY_PREFIX}")
    end
  end
end
