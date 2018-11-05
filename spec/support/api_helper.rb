module ApiHelper
  def api_url(action, params_hash = {})
    base_url = ApiHandler.base_url || "http://"
    path = ApiHandler.path(action)
    if params_hash.present?
      path += "&#{params_hash.to_param}"
    end
    Addressable::URI.parse "#{base_url}#{path}"
  end

  def api_stock_url
    api_url(:stock)
  end

  def api_deaccession_url
    api_url(:deaccession)
  end

  def api_scan_send_url(match)
    if match.request.del_type == "scan"
      api_scan_url
    else
      api_send_url
    end
  end

  def api_send_url
    api_url(:send)
  end

  def api_scan_url
    api_url(:scan)
  end

  def api_remove_request_url
    api_url(:archive_request)
  end

  def api_item_metadata_url(barcode)
    api_url(:record, barcode: barcode)
  end

  def api_item_url(item)
    api_item_metadata_url(item.barcode)
  end

  def api_requests_url
    api_url(:active_requests)
  end

  def stub_api_stock_item(item:, status_code: 200, body: nil)
    body ||= api_fixture_data("stock_item.json")
    stub_request(:post, api_stock_url).
      with(body: api_stock_item_params(item),
           headers: { "User-Agent" => "Faraday v0.15.3" }).
      to_return(status: status_code, body: body, headers: {})
  end

  def api_stock_item_params(item)
    {
      item_id: item.id.to_s,
      barcode: item.barcode,
      tray_code: item.tray.barcode
    }
  end

  def stub_api_deaccession_item(item:, status_code: 200, body: nil)
    body ||= api_fixture_data("deaccession_item.json")
    stub_request(:post, api_deaccession_url).
      with(body: api_deaccession_item_params(item),
           headers: { "User-Agent" => "Faraday v0.15.3" }).
      to_return(status: status_code, body: body, headers: {})
  end

  def api_deaccession_item_params(item)
    {
      barcode: item.barcode
    }
  end

  def stub_api_scan_send(match:, status_code: 200, body: nil)
    body ||= api_fixture_data("scan_send.json")
    stub_request(:post, api_scan_send_url(match)).
      with(body: api_scan_send_params(match),
           headers: { "User-Agent" => "Faraday v0.15.3" }).
      to_return(status: status_code, body: body, headers: {})
  end

  def stub_api_remove_request(request: request, status_code: 200, body: nil)
    stub_request(:post, api_remove_request_url).
      with(body: api_remove_request_params(request),
           headers: { "User-Agent" => "Faraday v0.15.3" }).
      to_return(status: status_code, body: body, headers: {})
  end

  def api_scan_send_delivery_type(match)
    if match.request.del_type == "scan"
      "scan"
    else
      "send"
    end
  end

  def api_scan_send_params(match)
    {
      item_id: match.item.id.to_s,
      barcode: match.item.barcode,
      tray_code: match.item.tray.barcode,
      source: match.request.source,
      transaction_num: match.request.trans.to_s,
      request_type: match.request.req_type,
      delivery_type: api_scan_send_delivery_type(match)
    }
  end

  def api_remove_request_params(request)
    {
      source: request.source,
      transaction_num: request.trans
    }
  end

  def stub_api_active_requests(status_code: 200, body: nil)
    body ||= api_fixture_data("active_requests.json")
    stub_request(:get, api_requests_url).
      with(headers: { "User-Agent" => "Faraday v0.15.3" }).
      to_return(status: status_code, body: body, headers: {})
  end

  def stub_api_item_metadata(barcode:, status_code: 200, body: nil)
    body ||= api_item_metadata_json(barcode)
    stub_request(:get, api_item_metadata_url(barcode)).
      with(headers: { "User-Agent" => "Faraday v0.15.3" }).
      to_return(status: status_code, body: body, headers: {})
  end

  def api_item_metadata_json(barcode)
    data = api_fixture_data("item_metadata.json")
    hash = JSON.parse(data)
    hash["barcode"] = barcode
    hash.to_json
  end

  def api_fixture_data(filename)
    File.read(Rails.root.join("spec/fixtures/api", filename))
  end
end
