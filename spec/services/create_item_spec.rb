require "rails_helper"

describe "CreateItem" do
  let(:thickness) { "11" }
  let(:item_barcode) { "12345678901234" }
  let(:flag) { "true" }
  let(:tray) { FactoryGirl.create(:tray) }
  let(:user) { FactoryGirl.create(:user) }
  subject { CreateItem.call(tray, item_barcode, user.id, thickness, flag) }

  describe "#create!" do
    it "create an item" do
      expect { subject }.to change { Item.count }.from(0).to(1)
    end
  end
end
