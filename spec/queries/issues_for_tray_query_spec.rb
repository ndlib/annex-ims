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

  context "issues not present for tray" do
    describe "#all_issues" do
      it "does not return any issues" do
        expect(subject.new(barcode: tray2.barcode).all_issues.count).to eq 0
      end
    end

    describe "#invalid_count_issues?" do
      it "returns false" do
        expect(subject.new(barcode: tray4.barcode).invalid_count_issues?).to be_falsey
      end
    end

    describe "#issues_by_type" do
      it "returns an empty array" do
        expect(subject.new(barcode: tray2.barcode).issues_by_type(type: "incorrect_count").count).to eq 0
      end
    end
  end

  context "issues present for tray" do
    describe "#all_issues" do
      it "returns issue" do
        expect(subject.new(barcode: tray.barcode).all_issues.count).to eq 1
      end

      it "returns all issues when multiple issues present" do
        expect(subject.new(barcode: tray3.barcode).all_issues.count).to eq 2
      end
    end

    describe "#invalid_count_issues?" do
      it "returns true when invalid count issue present" do
        expect(subject.new(barcode: tray3.barcode).invalid_count_issues?).to be_truthy
      end

      it "returns false when invalid count issue not present" do
        expect(subject.new(barcode: tray4.barcode).invalid_count_issues?).to be_falsey
      end
    end

    describe "#issues_by_type" do
      it "returns the correct number of issues by type for tray" do
        expect(subject.new(barcode: tray4.barcode).issues_by_type(type: "not_valid_barcode").count).to eq 1
        expect(subject.new(barcode: tray4.barcode).issues_by_type(type: "incorrect_count").count).to eq 0
      end

      it "returns empty array if type is not supplied" do
        expect(subject.new(barcode: tray4.barcode).issues_by_type(type: nil).count).to eq 0
      end
    end
  end
end
