require "rails_helper"

RSpec.describe ApiGetRequestList do
  let(:user_id) { 1 }
  context "self" do
    subject { described_class }

    describe "#call" do
      subject { described_class.call(user_id) }

      it "retrieves data" do
        stub_api_active_requests
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.success?).to eq(true)
        expect(subject.body).to be_a_kind_of(Array)
        expect(subject.body.count).to eq(2)
      end

      it "does not raise an exception on API failure" do
        stub_api_active_requests(status_code: 500, body: {}.to_json)
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.error?).to eq(true)
        expect(subject.body).to be_a_kind_of(Array)
        expect(subject.body.count).to eq(0)
      end
    end
  end
end
