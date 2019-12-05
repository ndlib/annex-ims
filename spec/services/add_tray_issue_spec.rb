require "rails_helper"

RSpec.describe AddTrayIssue do
  let(:tray) { FactoryBot.create(:tray) }
  let(:user) { FactoryBot.create(:user) }
  let(:issue_type) { "incorrect_count" }
  let(:message) { "tray was not found" }
  subject { described_class.call(tray: tray, user: user, type: issue_type, message: message) }

  it "creates an issue with the correct type, barcode, message and user" do
    expect { subject }.to change { TrayIssue.count }.from(0).to(1)
    expect(subject.user).to eq(user)
    expect(subject.issue_type).to eq(issue_type)
    expect(subject.barcode).to eq(tray.barcode)
    expect(subject.message).to eq(message)
  end

  it "logs the tray issue creation" do
    expect(ActivityLogger).to receive(:create_tray_issue).with(tray: tray, issue: kind_of(TrayIssue), user: user)
    subject
  end

  it "does not create a second issue for the same type" do
    issue = described_class.call(tray: tray, user: user, type: issue_type, message: message)
    expect(subject).to eq(issue)
  end

  it "creates a second issue for a different type" do
    issue = described_class.call(tray: tray, user: user, type: "not_valid_barcode", message: message)
    expect(subject).to_not eq(issue)
  end

  it "creates a second for a different tray" do
    other_tray = FactoryBot.create(:tray)
    issue = described_class.call(tray: other_tray, user: user, type: issue_type, message: message)
    expect(subject).to_not eq(issue)
  end
end
