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
      items = SearchItems.call(filter)

      request_data = {'requested' => request.requested,
        'id' => request.id,
        'rapid' => (request.rapid ? 'yes' : 'no'),
        'source' => request.source,
        'req_type' => request.req_type,
        'title' => request.title,
        'author' => request.author,
        'description' => request.description,
        'barcode' => request.barcode,
        'isbn_issn' => request.isbn_issn,
        'bib_number' => request.bib_number,
        'item_data' => []}

      items.each do |item|
        temp = {'id' => "#{request.id}-#{item.id}", 'shelf' => (!item.shelf.nil? ? item.shelf.barcode : ''), 'tray' => (!item.tray.nil? ? item.tray.barcode : ''), 'title' => item.title, 'author' => item.author, 'chron' => item.chron}

        request_data['item_data'] << temp
      end

      data << request_data
    end
Rails.logger.info data.inspect
    return data

  end

end
