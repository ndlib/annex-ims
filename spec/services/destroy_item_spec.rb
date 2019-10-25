require "rails_helper"

describe "DestroyItem" do
  let(:item) { FactoryBot.create(:item) }
  let(:user) { FactoryBot.create(:user) }
  subject { DestroyItem.call(item, user) }

  describe "#destroy!" do
    it "deletes one request" do
      item
      expect { subject }.to change { Item.count }.from(1).to(0)
    end

    it "returns true on success" do
      expect(subject).to be_truthy
    end

    it "logs the activity" do
      expect(ActivityLogger).to receive(:destroy_item).with(item: item, user: user).and_call_original
      subject
    end

    it "does not log the activity if it fails" do
      allow_any_instance_of(Item).to receive(:destroy!).and_return(false)
      expect(ActivityLogger).not_to receive(:destroy_item)
      subject
    end
  end
end
