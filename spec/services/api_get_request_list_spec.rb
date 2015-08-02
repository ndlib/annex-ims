require "rails_helper"

RSpec.describe ApiGetRequestList do
  let(:response) { ApiResponse.new(status_code: 200, body: { requests: [] }) }

  context "self" do
    subject { described_class }

    describe "#call" do
      subject { described_class.call }

      it "retrieves data" do
        stub_api_active_requests
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.success?).to eq(true)
        expect(subject.body["requests"]).to be_a_kind_of(Array)
        expect(subject.body["requests"].count).to eq(4)
        expect(subject.body["requests"].first["transaction"]).to eq("illiad-85132100")
      end

      it "logs the activity" do
        expect(ApiHandler).to receive(:get).and_return(response)
        expect(ActivityLogger).to receive(:api_get_request_list).with(api_response: kind_of(ApiResponse))
        subject
      end

      it "raises an exception on API failure" do
        stub_api_active_requests(status_code: 500, body: {}.to_json)
        expect { subject }.to raise_error(described_class::ApiGetRequestsError)
      end
    end
  end
end
