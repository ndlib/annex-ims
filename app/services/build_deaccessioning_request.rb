class BuildDeaccessioningRequest < GetRequests
  def self.call(item_id)
    new.build_request_data(item_id)
  end

  def initialize
  end

  def build_request_data(item_id)
    item = Item.where(id: item_id).take
    request_data = [{
      "transaction" => "DEACC-#{item_id}-#{Time.now.to_i}", # Need a bogus transaction
      "barcode" => item.barcode,
      "delivery_type" => "deaccessioning",
      "source" => "deaccessioning",
      "request_type" => "deaccessioning",
      "rush" => "No",
      "request_date_time" => Date.today.to_s,
      "title" => item.title,
      "author" => item.author,
      "isbn_issn" => item.isbn_issn,
      "bib_number" => item.bib_number
    }]

    update_requests(request_data)
  end
end
