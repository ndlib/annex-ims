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

      items.each do |item|
        data << {'source' => request.source, 'req_type' => request.req_type, 'rapid' => (request.rapid ? 'yes' : 'no'), 'shelf' => (!item.shelf.nil? ? item.shelf.barcode : ''), 'tray' => (!item.tray.nil? ? item.tray.barcode : ''), 'title' => item.title, 'author' => item.author, 'chron' => item.chron}
      end
    end

    return data

  end

end
