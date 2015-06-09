class ActivityLog < ActiveRecord::Base
  belongs_to :user
  belongs_to :object_item, class_name: "Item", foreign_key: "object_item_id"
  belongs_to :object_tray, class_name: "Tray", foreign_key: "object_tray_id"
  belongs_to :location_tray, class_name: "Tray", foreign_key: "location_tray_id"
  belongs_to :location_shelf, class_name: "Shelf", foreign_key: "location_shelf_id"
  belongs_to :location_bin, class_name: "Bin", foreign_key: "location_bin_id"

  validates_presence_of :user_id
  validates_presence_of :username
  validates_presence_of :action_timestamp
  validates_presence_of :object_barcode
  validates_presence_of :object_type
  validates_presence_of :action
end
