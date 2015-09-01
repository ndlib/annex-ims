require "rails_helper"

RSpec.describe BuildRequestData do
  let(:request_data) do
    {
      requested: "requested",
      rapid: "yes",
      source: "source",
      del_type: "del_type",
      req_type: "req_type",
      title: "title",
      author: "author",
      description: "description",
      barcode: "barcode",
      isbn_issn: "isbn_issn",
      bib_number: "bib_number"
    }
  end
  let(:item_data) do
    {
      status: "status",
      shelf: shelf,
      tray: tray,
      title: "title",
      author: "author",
      chron: "chron"
    }
  end
  let(:requests) { [instance_double(Request, id: 1, criteria_type: "bib_number", criteria: "bib_number", **request_data)] }
  let(:item) { instance_double(Item, id: 1, **item_data) }
  let(:results) { instance_double(Sunspot::Search::PaginatedCollection, total_pages: 1) }
  let(:search) { instance_double(Sunspot::Search::StandardSearch, results: results) }
  let(:shelf) { instance_double(Shelf, barcode: "shelf_barcode") }
  let(:tray) { instance_double(Tray, barcode: "tray_barcode") }

  context "found items" do
    before(:each) do
      allow(SearchItems).to receive(:call).and_return(search)
      allow(results).to receive(:each).and_yield(item)
    end

    it "returns request data" do
      result = described_class.call(requests)
      expect(result[0].symbolize_keys).to include(request_data)
    end

    it "returns item data for the request" do
      result = described_class.call(requests)
      expected_item_data = { id: "1-1", status: "status", shelf: "shelf_barcode", tray: "tray_barcode", title: "title", author: "author", chron: "chron" }
      expect(result[0]["item_data"]).to include(expected_item_data.stringify_keys)
    end

    it "returns no error when there aren't too many items to display for a request" do
      result = described_class.call(requests)
      expect(result[0]).not_to include("error")
    end

    it "returns an error when there are too many items to display for a request" do
      allow(results).to receive(:total_pages).and_return(2)
      result = described_class.call(requests)
      expect(result[0]).to include("error")
    end
  end

  context "no found items" do
    before(:each) do
      allow(SearchItems).to receive(:call).and_return(search)
      allow(search).to receive(:results).and_return(nil)
    end

    it "returns request data" do
      result = described_class.call(requests)
      expect(result[0].symbolize_keys).to include(request_data)
    end

    it "returns no item data for the request" do
      result = described_class.call(requests)
      expect(result[0]["item_data"]).to eq([])
    end
  end
end
