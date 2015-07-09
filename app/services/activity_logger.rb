class ActivityLogger
  DATA_OBJECTS = [:item, :tray, :shelf, :bin, :request, :issue, :api_response, :params]
  attr_reader :action, :user, :data_objects

  def self.accept_item(item:, request:, user:)
    call(action: "AcceptedItem", user: user, item: item, request: request)
  end

  def self.api_get_item_metadata(item:, params:, api_response:)
    call(action: "ApiGetItemMetadata", item: item, params: params, api_response: api_response)
  end

  def self.api_scan_item(item:, params:, api_response:)
    call(action: "ApiScanItem", item: item, params: params, api_response: api_response)
  end

  def self.api_send_item(item:, params:, api_response:)
    call(action: "ApiSendItem", item: item, params: params, api_response: api_response)
  end
  def self.api_stock_item(item:, params:, api_response:)
    call(action: "ApiStockItem", item: item, params: params, api_response: api_response)
  end

  def self.api_remove_request(request:, params:, api_response:)
    call(action: "ApiRemoveRequest", request: request, params: params, api_response: api_response)
  end

  def self.associate_item_and_bin(item:, bin:, user:)
    call(action: "AssociatedItemAndBin", user: user, item: item, bin: bin)
  end

  def self.associate_item_and_tray(item:, tray:, user:)
    call(action: "AssociatedItemAndTray", user: user, item: item, tray: tray)
  end

  def self.associate_tray_and_shelf(tray:, shelf:, user:)
    call(action: "AssociatedTrayAndShelf", user: user, tray: tray, shelf: shelf)
  end

  def self.create_issue(issue:, item:)
    call(action: "CreatedIssue", issue: issue, item: item)
  end

  def self.create_item(item:, user:)
    call(action: "CreatedItem", item: item, user: user)
  end

  def self.destroy_item(item:, user:)
    call(action: "DestroyedItem", item: item, user: user)
  end

  def self.dissociate_item_and_bin(item:, bin:, user:)
    call(action: "DissociatedItemAndBin", user: user, item: item, bin: bin)
  end

  def self.dissociate_item_and_tray(item:, tray:, user:)
    call(action: "DissociatedItemAndTray", user: user, item: item, tray: tray)
  end

  def self.dissociate_tray_and_shelf(tray:, shelf:, user:)
    call(action: "DissociatedTrayAndShelf", user: user, tray: tray, shelf: shelf)
  end

  def self.remove_request(request:, user:)
    call(action: "RemovedRequest", request: request, user: user)
  end

  def self.scan_item(item:, request:, user:)
    call(action: "ScannedItem", item: item, request: request, user: user)
  end

  def self.shelve_tray(tray:, shelf:, user:)
    call(action: "ShelvedTray", user: user, tray: tray, shelf: shelf)
  end

  def self.ship_item(item:, request:, user:)
    call(action: "ShippedItem", item: item, request: request, user: user)
  end

  def self.skip_item(item:, request:, user:)
    call(action: "SkippedItem", user: user, item: item, request: request)
  end

  def self.stock_item(item:, tray:, user:)
    call(action: "StockedItem", user: user, item: item, tray: tray)
  end

  def self.unshelve_tray(tray:, shelf:, user:)
    call(action: "UnshelvedTray", user: user, tray: tray, shelf: shelf)
  end

  def self.unstock_item(item:, tray:, user:)
    call(action: "UnstockedItem", user: user, item: item, tray: tray)
  end

  def self.update_item_metadata(item:)
    call(action: "UpdatedItemMetadata", item: item)
  end

  def self.call(action:, user: nil, **data_objects)
    new(action: action, user: user, **data_objects).log!
  end

  def initialize(action:, user: nil, **data_objects)
    @action = action
    @user = user
    @data_objects = data_objects
    validate_data_objects!
  end

  def data
    @data ||= {}.tap do |hash|
      data_objects.each do |key, object|
        hash[key.to_s] = object_data(object)
      end
    end
  end

  def username
    if user
      user.username
    end
  end

  def user_id
    if user
      user.id
    end
  end

  def log!
    ActivityLog.create!(
      action: action,
      data: data,
      username: username,
      user_id: user_id,
      action_timestamp: Time.now,
    )
  end

  def validate_data_objects!
    keys = data_objects.keys.map(&:to_sym)
    invalid_keys = keys - DATA_OBJECTS
    if invalid_keys.present?
      raise ArgumentError, "unknown keywords: #{invalid_keys.join(', ')}"
    end
  end

  private

  def object_data(object)
    if object.is_a?(Hash)
      object
    else
      object.attributes
    end
  end
end
