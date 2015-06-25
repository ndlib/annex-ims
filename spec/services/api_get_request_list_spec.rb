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
        expect(subject.body).to be_a_kind_of(Array)
        expect(subject.body.count).to eq(2)
        expect(subject.body.first).to eq(2)
      end
    end
  end
end
