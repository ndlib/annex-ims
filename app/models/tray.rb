class Tray < ActiveRecord::Base
  validates_presence_of :barcode
  validates :barcode, uniqueness: true
  validate :has_correct_prefix
  before_save :attach_tray_type

  belongs_to :shelf
  belongs_to :tray_type
  has_many :items, -> { order "updated_at DESC" }
  has_many :activity_logs, class_name: "ActivityLog", foreign_key: "object_tray_id"
  has_many :location_activity_logs, class_name: "ActivityLog", foreign_key: "location_tray_id"

  def has_correct_prefix
    if !IsTrayBarcode.call(barcode)
      errors.add(:barcode, "must begin with #{IsTrayBarcode.prefix}")
    end
  end

  def capacity
    capacity = tray_type.capacity + buffer
  end

  def buffer
    (items.count < 10) ? items.count : 10
  end

  def used
    items.sum(:thickness)
  end

  # Not entirely sure this is where this should go
  def style
    result = case used
      when 0..capacity then 'success'
      when capacity..(capacity + buffer - 1) then 'warning'
      else 'danger'
    end
    result
  end

  def type_code
    TraySize.call(barcode)
  end

  def attach_tray_type
    self.tray_type = TrayType.where(code: type_code).take
  end
end
