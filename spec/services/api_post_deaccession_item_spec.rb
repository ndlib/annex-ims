require "rails_helper"

RSpec.describe ApiPostDeaccessionItem do
  let(:tray) { FactoryBot.create(:tray) }
  let(:item) { FactoryBot.create(:item, tray: tray) }
  let(:response) { ApiResponse.new(status_code: 200, body: { "status" => "OK", "message" => "Item has been updated successfully" }) }

  context "self" do
    subject { described_class }

    describe "#call" do
      subject { described_class.call(item: item) }

      it "retrieves data" do
        expect(ApiHandler).to receive(:post).
          with(action: :deaccession, params: { barcode: item.barcode }).
          and_return(response)
        expect(ActivityLogger).to receive(:api_deaccession_item).with(item: item, params: anything, api_response: response)
        stub_api_deaccession_item(item: item)
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.success?).to eq(true)
        expect(subject.body).to eq("status" => "OK", "message" => "Item has been updated successfully")
      end

      it "raises an exception on API failure" do
        stub_api_deaccession_item(
          item: item,
          status_code: 500,
          body: {}.to_json
        )
        expect { subject }.to raise_error(described_class::ApiDeaccessionItemError)
      end

      it "raises an exception and adds an issue on unprocessable entities" do
        stub_api_deaccession_item(
          item: item,
          status_code: 422,
          body: { "status" => "error", "message" => "this is the error" }.to_json
        )
        expect(AddIssue).to receive(:call).with(hash_including(item: item, type: "aleph_error", message: "this is the error"))
        expect { subject }.to raise_error(described_class::ApiDeaccessionItemError)
      end

      it "raises an exception and adds an issue on unfound entities" do
        stub_api_deaccession_item(
          item: item,
          status_code: 404,
          body: { "status" => "error", "message" => nil }.to_json
        )
        expect(AddIssue).to receive(:call).with(hash_including(item: item, type: "aleph_error", message: nil))
        expect { subject }.to raise_error(described_class::ApiDeaccessionItemError)
      end
    end
  end
end
