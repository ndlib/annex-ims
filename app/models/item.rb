class Item < ActiveRecord::Base
  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  validate :has_correct_prefix

  belongs_to :tray

  def has_correct_prefix
    if !IsItemBarcode.call(barcode)
      errors.add(:barcode, "must not begin with #{IsShelfBarcode::PREFIX}, #{IsTrayBarcode::PREFIX}, or #{IsToteBarcode::PREFIX}")
    end
  end
end
