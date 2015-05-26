class ApiPostDeliverItem
  attr_reader :match_id

  def self.call(match_id)
    new(match_id).post_data!
  end

  def initialize(match_id)
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

    raw_results
  end

end
