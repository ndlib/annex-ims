require "rails_helper"

RSpec.describe IssuesForItemQuery do
  let(:item) { FactoryGirl.build(:item) }
  let(:item2) { FactoryGirl.build(:item) }
  let(:item3) { FactoryGirl.build(:item) }
  let!(:issue1) { FactoryGirl.create(:issue, issue_type: "not_for_annex", barcode: item.barcode) }
  let!(:issue2) { FactoryGirl.create(:issue, issue_type: "not_for_annex", barcode: item3.barcode) }
  let!(:issue3) { FactoryGirl.create(:issue, issue_type: "not_found", barcode: item3.barcode) }
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
end
