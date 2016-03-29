require "rails_helper"

RSpec.describe IssuesForItemQuery do
  let(:item) { FactoryGirl.build(:item) }
  let(:item2) { FactoryGirl.build(:item) }
  let(:item3) { FactoryGirl.build(:item) }
  let(:item4) { FactoryGirl.build(:item) }
  let!(:issue1) { FactoryGirl.create(:issue, issue_type: "not_for_annex", barcode: item.barcode) }
  let!(:issue2) { FactoryGirl.create(:issue, issue_type: "not_for_annex", barcode: item3.barcode) }
  let!(:issue3) { FactoryGirl.create(:issue, issue_type: "not_found", barcode: item3.barcode) }
  let!(:issue4) { FactoryGirl.create(:issue, issue_type: "not_valid_barcode", barcode: item4.barcode) }
  let(:subject) { described_class }

  context "no issues for item" do
    it "does not return any issues" do
      expect(subject.call(barcode: item2.barcode).count).to eq 0
    end
  end

  context "issues for item" do
    it "returns issue" do
      expect(subject.call(barcode: item.barcode).count).to eq 1
    end

    it "returns all issues when multiple issues present" do
      expect(subject.call(barcode: item3.barcode).count).to eq 2
    end
  end

  context "a comparison of item issues" do
    it "not for annex issue" do
      expect(issue1.barcode).to eq item.barcode
      expect(issue1.issue_type).to eq "not_for_annex"
      expect(issue1.issue_type).to_not eq "not_found"
      expect(issue1.issue_type).to_not eq "not_valid_barcode"
    end

    it "not found issue" do
      expect(issue3.barcode).to eq item3.barcode
      expect(issue3.issue_type).to eq "not_found"
      expect(issue3.issue_type).to_not eq "not_for_annex"
      expect(issue3.issue_type).to_not eq "not_valid_barcode"
    end

    it "not valid barcode issue" do
      expect(issue4.barcode).to eq item4.barcode
      expect(issue4.issue_type).to eq "not_valid_barcode"
      expect(issue4.issue_type).to_not eq "not_for_annex"
      expect(issue4.issue_type).to_not eq "not_found"
    end
  end
end
