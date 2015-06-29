class ApiPostDeliverItem
  API_PATH = "/1.0/resources/items/"

  attr_reader :match_id, :user

  def self.call(match_id, user)
    new(match_id, user).post_data!
  end

  def initialize(match_id, user)
    @user = user
    @match_id = match_id
  end

  def post_data!
    response = ApiHandler.post(action: delivery_type, params: params)

    if delivery_type == "send"
      ShipItem.call(match.item, user)  # This is inside out from StockItem, but works better this way, I think.
    else
      UnstockItem.call(match.item, user)  # Just in case it's not already unstocked, make sure.
      LogActivity.call(match.item, "Scanned", match.item.tray, Time.now, user)
    end

    response
  end

  def params
    {
      item_id: match.item.id,
      barcode: match.item.barcode,
      tray_code: match.item.tray.barcode,
      source: match.request.source,
      transaction_num: match.request.trans,
      request_type: match.request.req_type,
      delivery_type: delivery_type
    }
  end

  def delivery_type
    if match.request.del_type == "scan"
      "scan"
    else
      "send"
    end
  end

  def path(delivery_type)
    "#{API_PATH}#{delivery_type}"
  end

  private

  def match
    @match ||= Match.find(match_id)
  end

end
