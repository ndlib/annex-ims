class Item < ActiveRecord::Base
  require 'barcode_prefix'
  include BarcodePrefix

  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  validate :has_correct_prefix

  belongs_to :tray

  def has_correct_prefix
    if !is_item(barcode)
      errors.add(:barcode, "must not begin with #{SHELF_PREFIX}, #{TRAY_PREFIX}, or #{TOTE_PREFIX}")
    end
  end
end
