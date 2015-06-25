require "rails_helper"

RSpec.describe SyncItemMetadata do
  let(:barcode) { "00000007819006" }
  let(:item) { FactoryGirl.create(:item, barcode: barcode) }
  let(:user_id) { FactoryGirl.create(:user).id }

  context "self" do
    subject { described_class }

    describe "#call" do
      subject { described_class.call(item: item, user_id: user_id) }

      it "updates the item metadata" do
        stub_api_item_metadata(barcode: barcode)
        expect(subject).to eq(true)
        expect(item.title).to eq("The ubiquity of chaos / edited by Saul Krasner.")
        expect(item.author).to eq("Author")
        expect(item.chron).to eq("Description")
        expect(item.bib_number).to eq("000841979")
        expect(item.isbn_issn).to eq("0871683504")
        expect(item.conditions).to eq(["Condition"])
        expect(item.call_number).to eq("Q 172.5 .C45 U25 1990")
      end

      it "returns false when an error is encountered, adds an issue and destroys the item" do
        stub_api_item_metadata(barcode: barcode, status_code: 500, body: {}.to_json)
        expect(AddIssue).to receive(:call).and_call_original
        expect(subject).to eq(false)
        expect(Item.exists?(item.id)).to eq(false)
      end
    end
  end
end
