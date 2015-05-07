class Batch < ActiveRecord::Base
  has_many :matches
  has_many :requests, through: :matches
  has_many :items, through: :matches
  belongs_to :user

  validates_presence_of :user_id
end
