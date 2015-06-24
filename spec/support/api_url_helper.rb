module ApiUrlHelper
  def api_url(path, params_hash = {})
    base_url = Rails.application.secrets.api_server || "http:/"
    auth_token = Rails.application.secrets.api_token
    unless path =~ /^\//
      path = "/#{path}"
    end
    params = { auth_token: auth_token }.to_param
    if params_hash.present?
      params += "&#{params_hash.to_param}"
    end
    Addressable::URI.parse "#{base_url}#{path}?#{params}"
  end

  def api_stock_url
    api_url("1.0/resources/items/stock")
  end

  def api_send_url
    api_url("1.0/resources/items/send")
  end

  def api_item_url(item)
    api_url("1.0/resources/items/record", barcode: item.barcode)
  end
end
