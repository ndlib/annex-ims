class ApiPostDeliverItem
  attr_reader :match_id, :user

  def self.call(match_id, user)
    new(match_id, user).post_data!
  end

  def initialize(match_id, user)
    @user = user
    @match_id = match_id
    @path = "/1.0/resources/items"
  end

  def post_data!
    match = Match.find(@match_id)
    delivery_type = (match.request.del_type == "scan") ? "scan" : "send"
    path = "#{@path}/#{delivery_type}"

    params = { item_id: match.item.id, barcode: match.item.barcode, tray_code: match.item.tray.barcode, source: match.request.source, transaction_num: match.request.trans, request_type: match.request.req_type, delivery_type: delivery_type}

    begin
      raw_results = ApiHandler.call("POST", path, params)
    rescue Timeout::Error => e
      raw_results = {"status"=>599, "results"=>{"status"=>"NETWORK CONNECT TIMEOUT ERROR", "message"=>"Timeout Error"}}
    end

    if delivery_type == "send"
      ShipItem.call(match.item, user)  # This is inside out from StockItem, but works better this way, I think.
    else
      UnstockItem.call(match.item, user)  # Just in case it's not already unstocked, make sure.
      LogActivity.call(item, "Scanned", item.tray, Time.now, user)
    end

    raw_results
  end

end
