require "rails_helper"

RSpec.describe AddTrayIssue do
  let(:tray) { FactoryGirl.create(:tray) }
  let(:user) { FactoryGirl.create(:user) }
  let(:issue_type) { "counts_not_match" }
  let(:message) { "System count = 0. Manual count = 4." }
  subject { described_class.call(tray, 4, user) }

  it "creates a tray issue with the correct type, barcode, message and user" do
    expect { subject }.to change { Issue.count }.from(0).to(1)
    expect(subject.user).to eq(user)
    expect(subject.issue_type).to eq(issue_type)
    expect(subject.barcode).to eq(tray.barcode)
    expect(subject.message).to eq(message)
  end

  it "only updates the manual count of items inside the issue's message" do
    subject2 = AddTrayIssue.call(tray, 7, user)
    message2 = "System count = 0. Manual count = 7."
    expect(Issue.all.count).to eq(1)
    expect(subject2.user).to eq(user)
    expect(subject2.issue_type).to eq(issue_type)
    expect(subject2.barcode).to eq(tray.barcode)
    expect(subject2.message).to eq(message2)
  end

  it "logs the tray issue creation" do
    expect(ActivityLogger).to receive(:create_tray_issue).with( tray: tray,
      issue: kind_of(Issue), user: user)
    subject
  end
end
