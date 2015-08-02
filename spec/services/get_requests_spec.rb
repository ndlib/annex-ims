require "rails_helper"

RSpec.describe GetRequests do
  subject { described_class.call }
  let!(:item) { FactoryGirl.create(:item, barcode: "987654321") }

  it "creates requests" do
    stub_api_active_requests
    expect(SyncItemMetadata).to receive(:call).exactly(:once)
    expect { subject }.to change { Request.count }.by(4)
    expect(subject).to be_a_kind_of(Array)
    expect(subject.count).to eq(4)
    expect(subject.first.trans).to eq("illiad_85132100")
  end

  it "logs requests" do
    stub_api_active_requests
    expect(ActivityLogger).to receive(:receive_request).with(request: kind_of(Request)).exactly(4).times
    subject
  end
end
