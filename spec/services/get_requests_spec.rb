require "rails_helper"

RSpec.describe GetRequests do
  subject { described_class.call }

  it "creates requests" do
    stub_api_active_requests
    expect { subject }.to change { Request.count }.by(2)
    expect(subject).to be_a_kind_of(Array)
    expect(subject.count).to eq(2)
    expect(subject.first.trans).to eq("illiad_85132100")
  end
end
