require "rails_helper"

RSpec.describe ItemViewPresenter do
  let(:item) { FactoryGirl.build(:item) }
  let(:item2) { FactoryGirl.build(:item) }
  let!(:issue1) { FactoryGirl.create(:issue, issue_type: "not_for_annex", barcode: item.barcode) }
  let!(:issue2) { FactoryGirl.create(:issue, issue_type: "not_found", barcode: item.barcode) }

  context "no issues for item" do
    it "returns the plain status value" do
      item_presenter = described_class.new(item2)
      expect(item_presenter.status).to eq "stocked"
    end
  end

  context "issues for item" do
    it "returns the modified status value" do
      item_presenter = described_class.new(item)
      expect(item_presenter.status).to eq "stocked (on issue list)"
    end

    it "returns the modified status value when there are multiple issues" do
      item_presenter = described_class.new(item)
      expect(item_presenter.status).to eq "stocked (on issue list)"
    end
  end
end
