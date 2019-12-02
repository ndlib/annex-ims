class BuildDeaccessioningRequest < GetRequests
  def self.call(item_id, disposition_id, comment)
    new.build_request_data(item_id, disposition_id, comment)
  end

  def initialize; end

  def build_request_data(item_id, disposition_id, comment)
    item = Item.where(id: item_id).take
    SetItemDisposition.call(item_id, disposition_id)
    request_data = [{
      "transaction" => "REMOVE-#{item_id}-#{Time.now.to_i}", # Need a bogus transaction
      "barcode" => item.barcode,
      "delivery_type" => "deaccessioning",
      "source" => "deaccessioning",
      "request_type" => "deaccessioning",
      "rush" => "No",
      "request_date_time" => Date.today.to_s,
      "title" => item.title,
      "author" => item.author,
      "isbn_issn" => item.isbn_issn,
      "bib_number" => item.bib_number,
      "comment" => comment
    }]

    update_requests(request_data)
  end
end
