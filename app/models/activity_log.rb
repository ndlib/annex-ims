class ActivityLog < ActiveRecord::Base
  belongs_to :user

  validates :action_timestamp, presence: true
  validates :action, presence: true
  validates :data, presence: true
end
