class BuildRequestData

  attr_reader :requests

  def self.call(requests)
    new(requests).search!
  end

  def initialize(requests)
    @requests = requests
  end

  def search!
    data = []

    requests.each do |request|
      filter = {:criteria_type => request.criteria_type, :criteria => request.criteria}
      items = SearchItems.call(filter).results

      request_data = {"requested" => request.requested,
        "id" => request.id,
        "rapid" => (request.rapid ? "yes" : "no"),
        "source" => request.source,
        "del_type" => request.del_type,
        "req_type" => request.req_type,
        "title" => request.title,
        "author" => request.author,
        "description" => request.description,
        "barcode" => request.barcode,
        "isbn_issn" => request.isbn_issn,
        "bib_number" => request.bib_number,
        "item_data" => []}

      if !items.blank?
        items.each do |item|
          temp = {
            "id" => "#{request.id}-#{item.id}",
            "status" => item.status,
            "shelf" => (!item.shelf.nil? ? item.shelf.barcode : ""),
            "tray" => (!item.tray.nil? ? item.tray.barcode : ""),
            "title" => !item.title.nil? ? CGI.escapeHTML(item.title) : "",
            "author" => !item.author.nil? ? CGI.escapeHTML(item.author) : "",
            "chron" => !item.chron.nil? ? CGI.escapeHTML(item.chron) : ""
          }

          request_data["item_data"] << temp
        end
      end

      data << request_data
    end

    return data
  end
end
