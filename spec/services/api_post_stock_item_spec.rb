require "rails_helper"

RSpec.describe ApiPostStockItem do
  let(:tray) { FactoryBot.create(:tray) }
  let(:item) { FactoryBot.create(:item, tray: tray) }
  let(:response) { ApiResponse.new(status_code: 200, body: { "status" => "OK", "message" => "Item stocked" }) }

  context "self" do
    subject { described_class }

    describe "#call" do
      subject { described_class.call(item: item) }

      it "retrieves data" do
        expect(ApiHandler).to receive(:post).
          with(action: :stock, params: { item_id: item.id, barcode: item.barcode, tray_code: tray.barcode }).
          and_return(response)
        expect(ActivityLogger).to receive(:api_stock_item).with(item: item, params: anything, api_response: response)
        stub_api_stock_item(item: item)
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.success?).to eq(true)
        expect(subject.body).to eq("status" => "OK", "message" => "Item stocked")
      end

      it "raises an exception on API failure" do
        stub_api_stock_item(item: item, status_code: 500, body: {}.to_json)
        expect { subject }.to raise_error(described_class::ApiStockItemError)
      end

      it "raises an exception and adds an issue on unprocessable entities" do
        stub_api_stock_item(
          item: item,
          status_code: 422,
          body: { "status" => "error", "message" => "this is the error" }.to_json
        )
        expect(AddIssue).to receive(:call).with(hash_including(item: item, type: "aleph_error", message: "this is the error"))
        expect { subject }.to raise_error(described_class::ApiStockItemError)
      end
    end
  end
end
