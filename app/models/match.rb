class Match < ApplicationRecord
  belongs_to :batch
  belongs_to :request
  belongs_to :item
  belongs_to :bin

  validates :batch_id, presence: true
  validates :request_id, presence: true
  validates :item_id, presence: true
end
