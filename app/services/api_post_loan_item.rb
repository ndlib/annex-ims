class ApiPostLoanItem
  attr_reader :match_id

  def self.call(match_id)
    new(match_id).post_data!
  end

  def initialize(match_id)
    @match_id = match_id
    @path = "/1.0/resources/items/send"
  end

  def post_data!
    match = Match.find(@match_id)

    params = { item_id: match.item.id, barcode: match.item.barcode, tray_code: match.item.tray.barcode, source: match.request.source, transaction_num: match.request.trans, request_type: match.request.req_type, delivery_type: (match.request.del_type == "scan") ? "scan" : "send"}
p params.inspect
    raw_results = ApiHandler.call("POST", @path, params)
    results = {"status" => raw_results["status"], "results" => {}}
    raw_results
  end

end
