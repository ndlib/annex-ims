require "rails_helper"

RSpec.describe ApiPostStockItem do
  let(:tray) { FactoryGirl.create(:tray) }
  let(:item) { FactoryGirl.create(:item, tray: tray) }

  context "self" do
    subject { described_class }

    describe "#call" do
      subject { described_class.call(item: item) }

      it "retrieves data" do
        stub_api_stock_item(item: item)
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.success?).to eq(true)
        expect(subject.body).to eq("status" => "OK", "message" => "Item stocked")
      end

      it "does not raise an exception on API failure" do
        stub_api_stock_item(item: item, status_code: 500, body: {}.to_json)
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.error?).to eq(true)
        expect(subject.body).to eq({})
      end
    end
  end
end
