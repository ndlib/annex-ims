require "rails_helper"

RSpec.describe ApiPostDeliverItem do
  let(:match) { FactoryBot.create(:match, item: item, request: request) }
  let(:tray) { FactoryBot.create(:tray) }
  let(:item) { FactoryBot.create(:item, tray: tray) }
  let(:request) { FactoryBot.create(:request, del_type: "loan") }
  let(:response) { ApiResponse.new(status_code: 200, body: {}) }

  describe "#call" do
    subject { described_class.call(match: match) }

    context "send request" do
      it "retrieves data" do
        stub_api_scan_send(match: match)
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.success?).to eq(true)
        expect(subject.body).to eq("status" => "OK", "message" => "Item status updated")
      end

      it "posts the send action" do
        stub_api_scan_send(match: match)
        expect(ApiHandler).to receive(:post).with(action: "send", params: anything).and_return(response)
        expect(ActivityLogger).to receive(:api_send_item).with(item: item, params: anything, api_response: response)
        subject
      end

      it "raises an exception on API failure" do
        stub_api_scan_send(match: match, status_code: 500, body: {}.to_json)
        expect { subject }.to raise_error(described_class::ApiDeliverItemError)
      end
    end

    context "scan request" do
      let(:request) { FactoryBot.create(:request, del_type: "scan") }

      it "retrieves data" do
        stub_api_scan_send(match: match)
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.success?).to eq(true)
        expect(subject.body).to eq("status" => "OK", "message" => "Item status updated")
      end

      it "posts the scan action" do
        stub_api_scan_send(match: match)
        expect(ApiHandler).to receive(:post).with(action: "scan", params: anything).and_return(response)
        expect(ActivityLogger).to receive(:api_scan_item).with(item: item, params: anything, api_response: response)
        subject
      end
    end
  end
end
