require "rails_helper"

RSpec.describe GetItemFromBarcode do
  subject { described_class.call(user.id, barcode) }

  let(:user) { instance_double(User, username: "bob", id: 1) }
  let(:barcode) { "123456789" }

  before(:each) do
    allow(User).to receive(:find).and_return(user)
    allow(SyncItemMetadata).to receive(:call)
  end

  context "invalid barcode" do
    it "raises an error" do
      allow(IsItemBarcode).to receive(:call).and_return(false)
      expect { subject }.to raise_error
    end
  end

  context "given a valid item" do
    it "creates an item" do
      expect { subject }.to change { Item.count }.by(1)
    end

    it "logs the activity" do
      expect(LogActivity).to receive(:call).with(anything, "Created", anything, anything, anything).ordered
      subject
    end

    it "calls SyncItemMetadata" do
      expect(SyncItemMetadata).to receive(:call).with(item: kind_of(Item), user_id: user.id)
      subject
    end

    it "returns the item on successful sync" do
      expect(SyncItemMetadata).to receive(:call).and_return(true)
      expect(subject).to be_kind_of(Item)
    end

    it "returns nil on failed sync" do
      expect(SyncItemMetadata).to receive(:call).and_return(false)
      expect(subject).to be_nil
    end
  end
end
