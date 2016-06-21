require "rails_helper"

RSpec.describe IssuesForTrayQuery do
  let(:tray) { FactoryGirl.build(:tray) }
  let(:tray2) { FactoryGirl.build(:tray) }
  let(:tray3) { FactoryGirl.build(:tray) }
  let(:tray4) { FactoryGirl.build(:tray) }
  let!(:tray_issue1) { FactoryGirl.create(:tray_issue, issue_type: "incorrect_count", barcode: tray.barcode) }
  let!(:tray_issue2) { FactoryGirl.create(:tray_issue, issue_type: "incorrect_count", barcode: tray3.barcode) }
  let!(:tray_issue3) { FactoryGirl.create(:tray_issue, issue_type: "not_valid_barcode", barcode: tray3.barcode) }
  let!(:tray_issue4) { FactoryGirl.create(:tray_issue, issue_type: "not_valid_barcode", barcode: tray4.barcode) }
  let(:subject) { described_class }

  context "no issues for tray" do
    it "does not return any issues" do
      expect(subject.call(barcode: tray2.barcode).count).to eq 0
    end
  end

  context "issues for tray" do
    it "returns issue" do
      expect(subject.call(barcode: tray.barcode).count).to eq 1
    end

    it "returns all issues when multiple issues present" do
      expect(subject.call(barcode: tray3.barcode).count).to eq 2
    end
  end

  context "a comparison of tray issues" do
    it "not for annex issue" do
      expect(tray_issue1.barcode).to eq tray.barcode
      expect(tray_issue1.issue_type).to eq "incorrect_count"
      expect(tray_issue1.issue_type).to_not eq "not_valid_barcode"
    end

    it "not found issue" do
      expect(tray_issue3.barcode).to eq tray3.barcode
      expect(tray_issue3.issue_type).to eq "not_valid_barcode"
      expect(tray_issue3.issue_type).to_not eq "incorrect_count"
    end

    it "not valid barcode issue" do
      expect(tray_issue4.barcode).to eq tray4.barcode
      expect(tray_issue4.issue_type).to eq "not_valid_barcode"
      expect(tray_issue4.issue_type).to_not eq "incorrect_count"
    end
  end
end
