require "rails_helper"

describe "CreateItem" do
  let(:thickness) { "11" }
  let(:barcode) { "12345678904444" }
  let(:tray) { FactoryGirl.create(:tray) }
  let(:user) { FactoryGirl.create(:user) }
  let(:item) { FactoryGirl.create(:item, barcode: barcode) }
  subject { CreateItem.call(tray, item.barcode, user.id, thickness, nil) }

  describe "#create!" do
    it "create an item" do
      expect(GetItemFromBarcode).to receive(:call).with(barcode: item.barcode, user_id: user.id).and_return(item).at_least :once
        stub_request(:post, api_stock_url).
        with(body: { "barcode" => "#{item.barcode}", "item_id" => "#{item.id}", "tray_code" => "#{tray.barcode}" },
          headers: { "Content-Type" => "application/x-www-form-urlencoded", "User-Agent" => "Faraday v0.9.1" }).
        to_return{ { status: 200, body: { results: { status: "OK", message: "Item stocked" } }.to_json, headers: {} } }
      expect(subject).to eq("Item #{barcode} stocked in #{tray.barcode}.")
    end
  end
end
