class TrayType < ActiveRecord::Base
  validates :code,
            :trays_per_shelf,
            :height,
            presence: true
  validates :code, uniqueness: true
  validates_inclusion_of :active, :in => [true, false]
  validates_inclusion_of :unlimited, :in => [true, false]
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
  validates_presence_of :capacity, if: -> { !unlimited }
  before_save :null_unlimited_capacity

  has_many :trays

  def null_unlimited_capacity
    self.capacity = nil if self.unlimited
  end
end
