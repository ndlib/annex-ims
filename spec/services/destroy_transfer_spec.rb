require "rails_helper"

describe "DestroyTransfer" do
  let(:tray) { FactoryBot.create(:tray, barcode: "TRAY-AL123") }
  let(:tray2) { FactoryBot.create(:tray, barcode: "TRAY-AL456") }
  let(:tray3) { FactoryBot.create(:tray, barcode: "TRAY-AL789") }
  let(:tray4) { FactoryBot.create(:tray, barcode: "TRAY-AL987") }
  let(:shelf) { FactoryBot.create(:shelf, trays: [tray, tray3, tray4], barcode: "SHELF-AL123") }
  let(:shelf2) { FactoryBot.create(:shelf, trays: [tray2], barcode: "SHELF-AL456") }
  let(:shelf3) { FactoryBot.create(:shelf, trays: [], barcode: "SHELF-AL789") }
  let(:transfer) { FactoryBot.create(:transfer, shelf: shelf, initiated_by: user) }
  let(:transfer2) { FactoryBot.create(:transfer, shelf: shelf2, initiated_by: user) }
  let(:user) { FactoryBot.create(:user) }
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
      expect(subject).to eq "success"
    end

    it "returns an error message when failed" do
      transfer
      transfer2
      expect(transfer).to receive(:destroy!).and_raise("error")
      expect(subject).to eq "error"
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
