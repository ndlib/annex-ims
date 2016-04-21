require "rails_helper"

describe "CreateItem" do
  let(:thickness) { "11" }
  let(:barcode) { "12345678904444" }
  let(:tray) { FactoryGirl.create(:tray) }
  let(:user) { FactoryGirl.create(:user) }
  let(:item) { FactoryGirl.create(:item, barcode: barcode) }
  subject { CreateItem.call(tray, item.barcode, user.id, thickness, nil) }

  describe "#create!" do
    it "create an item" do
      expect { subject }.to change { Item.count }.from(0).to(1)
      expect(subject).to eq("Item #{barcode} stocked in #{tray.barcode}.");
    end
  end
end
