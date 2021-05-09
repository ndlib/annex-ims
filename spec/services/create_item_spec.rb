require "rails_helper"

describe "CreateItem" do
  let(:thickness) { "11" }
  let(:barcode) { "12345678904444" }
  let(:tray) { FactoryBot.create(:tray) }
  let(:user) { FactoryBot.create(:user) }
  let(:item) { FactoryBot.create(:item, barcode: barcode) }
  subject { CreateItem.call(tray, item.barcode, user.id, thickness, nil) }

  describe "#create!" do
    it "create an item" do
      expect(GetItemFromBarcode).to receive(:call).with(barcode: item.barcode, user_id: user.id).and_return(item).at_least :once
      stub_request(:post, api_stock_url).
        with(body: { "barcode" => item.barcode.to_s, "item_id" => item.id.to_s, "tray_code" => tray.barcode.to_s },
             headers: { "Content-Type" => "application/x-www-form-urlencoded", "User-Agent" => "Faraday v0.17.4" }).
        to_return { { status: 200, body: { results: { status: "OK", message: "Item stocked" } }.to_json, headers: {} } }
      expect(subject).to eq("Item #{barcode} stocked in #{tray.barcode}.")
    end
  end
end
