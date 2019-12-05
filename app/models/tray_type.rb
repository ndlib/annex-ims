class TrayType < ApplicationRecord
  validates :code,
            :trays_per_shelf,
            :height,
            presence: true
  validates :code, uniqueness: { conditions: -> { where(active: true) } }
  validates :active, inclusion: { in: [true, false] }
  validates :unlimited, inclusion: { in: [true, false] }
  validates :capacity,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              allow_nil: true
            }
  validates :trays_per_shelf, :height,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0
            },
            length: { maximum: 2 }
  validates :capacity, presence: { if: -> { !unlimited } }
  before_save :null_unlimited_capacity

  has_many :trays

  def null_unlimited_capacity
    self.capacity = nil if unlimited
  end
end
