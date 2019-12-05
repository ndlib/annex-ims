require "rails_helper"

RSpec.describe DissociateItemFromBin do
  let(:shelf) { FactoryBot.create(:shelf) }
  let(:tray) { FactoryBot.create(:tray, shelf: shelf) }
  let(:item) { FactoryBot.create(:item, tray: tray, thickness: 1, bin: bin) }
  let(:bin) { FactoryBot.create(:bin) }
  let(:match) { FactoryBot.create(:match, item: item, bin: bin, request: request) }
  let(:user) { FactoryBot.create(:user) }
  let(:request) { FactoryBot.create(:request, del_type: "loan") }

  subject { described_class.call(item: item, user: user) }

  context "when there are remaining matches for the associated item" do
    before(:each) do
      request2 = FactoryBot.create(:request, del_type: "loan")
      FactoryBot.create(:match, item: item, bin: bin, request: request2)
    end

    it "doesn't dissociate the bin and item" do
      subject
      expect(item.bin).to eq(bin)
    end

    it "doesn't log a dissociation of bin and item" do
      expect(ActivityLogger).not_to receive(:dissociate_item_and_bin).with(item: item, bin: bin, user: user)
      subject
    end

    it "does not dissociate the bin from the match that was processed" do
      subject
      expect(item.bin).to eq(bin)
    end
  end

  context "when there are no remaining matches for the associated item" do
    it "dissociates the bin from the associated item" do
      subject
      expect(item.bin).to be_nil
    end

    it "logs a dissociation of bin and item" do
      expect(ActivityLogger).to receive(:dissociate_item_and_bin).with(item: item, bin: bin, user: user)
      subject
    end

    it "dissociates the bin from the match that was processed" do
      subject
      expect(item.bin).to be_nil
    end

    it "deaccessions items that are in a deaccessioning bin when processed" do
      item.bin.barcode = "BIN-REM-STOCK-01"
      item.bin.save!
      expect(DeaccessionItem).to receive(:call).with(item, user)
      subject
    end
  end
end
