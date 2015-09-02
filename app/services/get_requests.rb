class GetRequests
  def self.call
    new.get_data!
  end

  def initialize
  end

  def get_data!
    response = ApiGetRequestList.call

    update_requests(response.body[:requests])
  end

  private

  def update_requests(requests_data)
    requests = []
    requests_data.each do |request_data|
      attributes = request_attributes(request_data)
      request = create_or_update_request(attributes)
      if request.present?
        requests << request
      end
    end
    requests
  end

  def create_or_update_request(attributes)
    request = Request.find_or_initialize_by(trans: attributes["trans"])
    new_record = request.new_record?
    begin
    request.attributes = attributes
    unless attributes["barcode"].blank?
      update_item_metadata(attributes["barcode"])
    end
    request.save!
    if new_record
      ActivityLogger.receive_request(request: request)
    end
    request
    rescue StandardError => e
      NotifyError.call(exception: e, parameters: { attributes: attributes, request: request }, component: self.class.to_s, action: "create_or_update_request")
      nil
    end
  end

  def request_attributes(request_data)
    if !request_data["barcode"].blank?
      criteria_type = "barcode"
      criteria = request_data["barcode"]
    elsif !request_data["bib_number"].blank?
      criteria_type = "bib_number"
      criteria = request_data["bib_number"]
    elsif !request_data["isbn_issn"].blank?
      criteria_type = "isbn_issn"
      criteria = request_data["isbn_issn"]
    elsif !request_data["title"].blank?
      criteria_type = "title"
      criteria = request_data["title"]
    else
      criteria_type = "ERROR" # Quick hack to cover when not available.
      criteria = "ERROR"
    end

    del_type = request_data["delivery_type"].downcase
    source = request_data["source"].downcase

    req_type = request_data["request_type"].downcase.gsub(" ", "_")

    if (request_data["rush"] == "No") || (request_data["rush"] == "Regular")
      rapid = false
    else
      rapid = true
    end

    trans = request_data["transaction"].gsub("doc-del", "aleph").gsub("-", "_")

    {
      "trans" => trans,
      "criteria_type" => criteria_type,
      "criteria" => criteria,
      "requested" => request_data["request_date_time"],
      "rapid" => rapid,
      "source" => source,
      "del_type" => del_type,
      "req_type" => req_type,
      "title" => request_data["title"],
      "article_title" => request_data["article_title"],
      "author" => request_data["author"],
      "description" => request_data["description"],
      "barcode" => request_data["barcode"],
      "isbn_issn" => request_data["isbn_issn"],
      "bib_number" => request_data["bib_number"],
      "patron_institution" => request_data["patron_institution"],
      "patron_department" => request_data["patron_department"],
      "patron_status" => request_data["patron_status"],
      "pickup_location" => request_data["pickup_location"],
    }
  end

  def update_item_metadata(barcode)
    item = Item.where(barcode: barcode).take
    SyncItemMetadataJob.perform_later(item: item, user_id: nil) if item
  end
end
