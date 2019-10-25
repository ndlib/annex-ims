require "spec_helper"

RSpec.describe UnresolvedTrayIssueQuery do
  subject { described_class }

  it "will query for all tray_issues that have not been resolved" do
    relation = double
    expect(relation).to receive(:where).with(resolved_at: nil)
    subject.call({}, relation: relation)
  end

  it "will allow filtering by barcode" do
    tray_issue1 = FactoryBot.create(:tray_issue)
    tray_issue2 = FactoryBot.create(:tray_issue)

    # This one won't show up in the response object
    FactoryBot.create(:tray_issue, resolved_at: Time.zone.now)

    # Overloading expectations so we don't need
    expect(subject.call(barcode: tray_issue1.barcode)).to eq([tray_issue1])
    expect(subject.call(barcode: "")).to eq([tray_issue1, tray_issue2])
    expect(subject.call({})).to eq([tray_issue1, tray_issue2])
  end
end
