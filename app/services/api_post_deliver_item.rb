class ApiPostDeliverItem
  class ApiDeliverItemError < StandardError; end
  attr_reader :match

  def self.call(match:)
    new(match: match).post_data!
  end

  def initialize(match:)
    @match = match
  end

  def post_data!
    response = ApiHandler.post(action: delivery_type, params: params)
    if response.success?
      log_activity(response)
      response
    else
      log_activity(response)
      raise ApiDeliverItemError, "Error sending #{delivery_type} request to API. params: #{params.inspect}, response: #{response.inspect}"
    end
  end

  private

  def log_activity(response)
    case delivery_type
    when "scan"
      ActivityLogger.api_scan_item(item: item, params: params, api_response: response)
    when "send"
      ActivityLogger.api_send_item(item: item, params: params, api_response: response)
    end
  end

  def params
    {
      item_id: item.id,
      barcode: item.barcode,
      tray_code: tray_code,
      source: request.source,
      transaction_num: request.trans,
      request_type: request.req_type,
      delivery_type: delivery_type
    }
  end

  def item
    match.item
  end

  def request
    match.request
  end

  def tray_code
    item.tray ? item.tray.barcode : nil
  end

  def delivery_type
    if request.del_type == "scan"
      "scan"
    else
      "send"
    end
  end

end
