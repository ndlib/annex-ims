class Issue < ActiveRecord::Base
  validates :user_id, presence: true
  validates :barcode, presence: true
  validates :message, presence: true

  belongs_to :user
  belongs_to :resolver, class_name: "User"
end
