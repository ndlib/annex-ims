class ActivityLog < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :action_timestamp
  validates_presence_of :action
  validates_presence_of :data
end
