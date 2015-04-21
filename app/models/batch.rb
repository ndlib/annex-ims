class Batch < ActiveRecord::Base
  has_many :requests
  has_and_belongs_to_many :items
  belongs_to :user
end
