class Match < ActiveRecord::Base
  belongs_to :batch
  belongs_to :request
  belongs_to :item
  belongs_to :bin

  validates_presence_of :batch_id
  validates_presence_of :request_id
  validates_presence_of :item_id
  validates :bin_id, presence: true
end
