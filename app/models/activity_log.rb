class ActivityLog < ApplicationRecord
  belongs_to :user

  validates :action_timestamp, presence: true
  validates :action, presence: true
  validates :data, presence: true
end
