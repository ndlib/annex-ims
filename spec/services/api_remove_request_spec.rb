require "rails_helper"

RSpec.describe ApiRemoveRequest do
  let(:user_id) { 1 }
  let(:request) { FactoryGirl.create(:request) }

  describe "#call" do
    subject { described_class.call(request: request) }

    it "responds with success" do
      stub_api_remove_request(request: request, body: {
        "status" => "OK",
        "message" => "Request removed" }.to_json)
      expect(ActivityLogger).to receive(:api_remove_request).with(request: request, params: {source: request.source, transaction_num: request.trans}, api_response: kind_of(ApiResponse))
      expect(subject).to be_a_kind_of(ApiResponse)
      expect(subject.success?).to eq(true)
      expect(subject.body).to be_a_kind_of(Hash)
      expect(subject.body["status"]).to eq("OK")
    end

    it "responds with an error when call fails" do
      stub_api_remove_request(request: request, status_code: 500, body: {}.to_json)
      expect(subject).to be_a_kind_of(ApiResponse)
      expect(subject.error?).to eq(true)
      expect(subject.body).to be_a_kind_of(Hash)
    end
  end
end
