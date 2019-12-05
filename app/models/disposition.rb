class Disposition < ApplicationRecord
  validates :code, presence: true
  validates :code, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
  has_many :items
end
