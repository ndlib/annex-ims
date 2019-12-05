require "rails_helper"

RSpec.describe GetItemFromBarcode do
  subject { described_class.call(barcode: barcode, user_id: user_id) }

  let(:user_id) { user.id }
  let(:user) { instance_double(User, username: "bob", id: 1) }
  let(:barcode) { "123456789" }

  before(:each) do
    allow(User).to receive(:find).and_return(user)
    allow(SyncItemMetadata).to receive(:call)
  end

  context "invalid barcode" do
    it "raises an error" do
      allow(IsItemBarcode).to receive(:call).and_return(false)
      expect { subject }.to raise_error("barcode is not an item")
    end
  end

  context "new item" do
    it "creates an item" do
      expect { subject }.to change { Item.count }.by(1)
    end

    it "logs the activity" do
      expect(ActivityLogger).to receive(:create_item).with(item: kind_of(Item), user: user)
      subject
    end

    it "calls SyncItemMetadata" do
      expect(SyncItemMetadata).to receive(:call).with(item: kind_of(Item), user_id: user.id)
      subject
    end

    it "returns the item" do
      expect(subject).to be_kind_of(Item)
    end
  end

  context "existing item" do
    let(:metadata_status) { "pending" }
    let(:item) { instance_double(Item, metadata_status: metadata_status) }

    before do
      allow_any_instance_of(described_class).to receive(:item).and_return(item)
    end

    context "not_found status" do
      let(:metadata_status) { "not_found" }

      it "returns nil" do
        expect(subject).to be_nil
      end
    end

    context "error status" do
      let(:metadata_status) { "error" }

      it "returns the item" do
        expect(subject).to eq(item)
      end
    end

    context "complete status" do
      let(:metadata_status) { "complete" }

      it "returns the item" do
        expect(subject).to eq(item)
      end
    end

    context "pending status" do
      let(:metadata_status) { "pending" }

      it "returns the item" do
        expect(subject).to eq(item)
      end
    end
  end
end
