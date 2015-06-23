class LogActivity
  attr_reader :object, :action, :location, :action_timestamp, :user

  def self.call(object, action, location, action_timestamp, user)
    new(object, action, location, action_timestamp, user).log!
  end

  def initialize(object, action, location, action_timestamp, user)
    @object = object
    @action = action
    @location = location
    @action_timestamp = action_timestamp
    @user = user
  end

  def log!
    activity = ActivityLog.new

    activity.object_barcode = @object.barcode
    activity.object_type = @object.class.to_s

    if @object.class.to_s == "Item"
      activity.object_item_id = @object.id
    elsif @object.class.to_s == "Tray"
      activity.object_tray_id = @object.id
    end

    activity.action = @action

    if @action != "Created"
      activity.location_barcode = @location.barcode
      activity.location_type = @location.class.to_s

      if @location.class.to_s == "Tray"
        activity.location_tray_id = @location.id
      elsif @location.class.to_s == "Shelf"
        activity.location_shelf_id = @location.id
      elsif @location.class.to_s == "Bin"
        activity.location_bin_id = @location.id
      end

    end

    activity.action_timestamp = @action_timestamp

    activity.username = @user.username
    activity.user_id = @user.id

    activity.save!
  end

end
