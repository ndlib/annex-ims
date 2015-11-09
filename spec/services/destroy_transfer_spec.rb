require "rails_helper"

describe "DestroyTransfer" do
  let(:tray) { FactoryGirl.create(:tray, barcode: "TRAY-AL123") }
  let(:tray2) { FactoryGirl.create(:tray, barcode: "TRAY-AL456") }
  let(:tray3) { FactoryGirl.create(:tray, barcode: "TRAY-AL789") }
  let(:tray4) { FactoryGirl.create(:tray, barcode: "TRAY-AL987") }
  let(:shelf) { FactoryGirl.create(:shelf, trays: [tray, tray3, tray4], barcode: "SHELF-AL123") }
  let(:shelf2) { FactoryGirl.create(:shelf, trays: [tray2], barcode: "SHELF-AL456") }
  let(:shelf3) { FactoryGirl.create(:shelf, trays: [], barcode: "SHELF-AL789") }
  let(:transfer) { FactoryGirl.create(:transfer, shelf: shelf, initiated_by: user) }
  let(:transfer2) { FactoryGirl.create(:transfer, shelf: shelf2, initiated_by: user) }
  let(:user) { FactoryGirl.create(:user) }
  subject { DestroyTransfer.call(transfer, user) }

  describe "#destroy" do
    it "deletes one transfer" do
      transfer
      transfer2
      expect(Transfer.all.count).to eq 2
      subject
      expect(Transfer.all.count).to eq 1
    end

    it "returns true on success" do
      transfer
      transfer2
      expect(subject).to be_truthy
    end

    it "logs the activity" do
      transfer
      transfer2
      expect(ActivityLogger).to receive(:destroy_transfer).with(shelf: shelf, transfer: transfer, user: user).and_call_original
      subject
    end
  end

  describe ".shelve_trays" do
    it "reshelves remaining trays for transfer shelf" do
      transfer
      transfer2
      expect(ShelveTray).to receive(:call).exactly(3).times
      subject
    end
  end
end
