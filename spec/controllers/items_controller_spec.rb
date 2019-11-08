require "rails_helper"

RSpec.describe ItemsController, type: :controller do
  let(:user) { FactoryBot.create(:user, admin: true) }

  before(:each) do
    sign_in(user)
  end

  describe "POST refresh" do
    let(:item) { FactoryBot.create(:item) }
    subject { post :refresh, params: { barcode: item.barcode } }

    context "for an invalid barcode" do
      it "flashes an error" do
        post :refresh, params: { barcode: "invalid barcode" }
        expect(flash[:error]).to include("invalid barcode")
      end
    end

    context "for a valid barcode thats not found" do
      subject { post :refresh, params: { barcode: "valid barcode" } }

      before(:each) do
        allow(IsValidItem).to receive(:call).and_return(true)
        allow(ActivityLogger).to receive(:create_item)
        allow(SyncItemMetadata).to receive(:call)
        allow(Item).to receive(:new).and_return(item)
      end

      it "creates a new item" do
        expect(Item).to receive(:new).and_return(item)
        expect(item).to receive(:save!).and_return(true)
        subject
      end

      it "logs a create item" do
        expect(ActivityLogger).to receive(:create_item).with(item: item, user: user)
        subject
      end

      it "syncs metadata" do
        expect(SyncItemMetadata).to receive(:call).with(item: item, user_id: user.id)
        subject
      end
    end

    context "for a valid barcode that is not found" do

      before(:each) do
        allow(IsValidItem).to receive(:call).and_return(true)
        allow(ActivityLogger).to receive(:create_item)
        allow(SyncItemMetadata).to receive(:call)
        allow(Item).to receive(:new).and_return(item)
      end

      it "doesn't create a new item" do
        expect(Item).to_not receive(:new)
        expect(item).to_not receive(:save!)
        subject
      end

      it "logs a create item" do
        expect(ActivityLogger).to_not receive(:create_item).with(item: item, user: user)
        subject
      end

      it "syncs metadata" do
        expect(SyncItemMetadata).to receive(:call).with(item: item, user_id: user.id)
        subject
      end
    end
  end
end
