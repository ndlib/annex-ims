require "rails_helper"

RSpec.describe AddIssue do
  let(:item) { FactoryGirl.create(:item) }
  let(:user) { FactoryGirl.create(:user) }
  let(:issue_type) { "not_found" }
  subject { described_class.call(item: item, user: user, type: issue_type) }

  it "creates an issue with the correct type, barcode and user" do
    expect { subject }.to change { Issue.count }.from(0).to(1)
    expect(subject.user).to eq(user)
    expect(subject.issue_type).to eq(issue_type)
    expect(subject.barcode).to eq(item.barcode)
  end

  it "logs the issue creation" do
    expect(ActivityLogger).to receive(:create_issue).with(item: item, issue: kind_of(Issue), user: user)
    subject
  end

  it "does not create a second issue for the same type" do
    issue = described_class.call(item: item, user: user, type: issue_type)
    expect(subject).to eq(issue)
  end

  it "creates a second issue for a different type" do
    issue = described_class.call(item: item, user: user, type: "not_for_annex")
    expect(subject).to_not eq(issue)
  end

  it "creates a second for a different item" do
    other_item = FactoryGirl.create(:item)
    issue = described_class.call(item: other_item, user: user, type: issue_type)
    expect(subject).to_not eq(issue)
  end
end
