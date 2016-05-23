require "rails_helper"


RSpec.describe ResolveTrayIssue do
  let(:tray) { FactoryGirl.create(:tray) }
  let(:user) { FactoryGirl.create(:user) }
  let(:issue) { FactoryGirl.create(:issue, user_id: user.id, barcode: tray.barcode,
    issue_type: "counts_not_match", barcode_type: "tray") }
  subject { described_class.call(tray, user) }

  it "resolves the issue" do
    expect(issue.resolver).to be_nil
    subject
    expect(issue.reload.resolver).to eq(user)
  end

  it "resolves the tray issue" do
    expect(ActivityLogger).to receive(:resolve_issue).with(issue: issue, user: user)
    subject
  end
end
