require 'rails_helper'

RSpec.describe DissociateItemFromBin do
  let(:shelf) { FactoryGirl.create(:shelf) }
  let(:tray) { FactoryGirl.create(:tray, shelf: shelf) }
  let(:item) { FactoryGirl.create(:item, tray: tray, thickness: 1, bin: bin) }
  let(:bin) { FactoryGirl.create(:bin) }
  let(:match) { FactoryGirl.create(:match, item: item, bin: bin, request: request) }
  let(:user) { FactoryGirl.create(:user) }
  let(:request) { FactoryGirl.create(:request, del_type: "loan") }

  subject { described_class.call(item: item, user: user) }

  context "when there are remaining matches for the associated item" do
    before(:each) do
      request2 = FactoryGirl.create(:request, del_type: "loan")
      FactoryGirl.create(:match, item: item, bin: bin, request: request2)
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
  end
end
