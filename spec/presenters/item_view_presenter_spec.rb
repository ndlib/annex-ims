require "rails_helper"

RSpec.describe ItemViewPresenter do
  let(:shelf) { FactoryGirl.create(:shelf) }
  let(:tray) { FactoryGirl.create(:tray, shelf: shelf) }
  let(:user) { FactoryGirl.create(:user) }

  let(:item1) { FactoryGirl.build(:item, tray: tray, status: 1) }
  let(:item2) { FactoryGirl.build(:item, tray: tray, status: 0) }
  let(:item3) { FactoryGirl.build(:item, tray: tray, status: 2) }
  let(:item4) { FactoryGirl.build(:item, tray: tray, status: 0) }
  let(:item5) { FactoryGirl.build(:item, tray: tray, status: 1) }
  let(:bin) { FactoryGirl.create(:bin, items: [item5]) }
  let!(:issue1) { FactoryGirl.create(:issue, issue_type: "not_for_annex", barcode: item1.barcode) }
  let!(:issue2) { FactoryGirl.create(:issue, issue_type: "not_found", barcode: item2.barcode) }

  context "no issues for item" do
    it "returns the plain status value" do
      item_presenter = described_class.new(item3)
      expect(item_presenter.status).to eq "shipped"
    end
  end

  context "issues for item" do
    it "returns the modified status value" do
      item_presenter = described_class.new(item1)
      expect(item_presenter.status).to eq "unstocked (on issue list)"
    end

    it "returns the modified status value when there are multiple issues" do
      item_presenter = described_class.new(item2)
      expect(item_presenter.status).to eq "stocked (on issue list)"
    end
  end
end
