require "rails_helper"

describe "DestroyItem" do
  let(:item) { FactoryGirl.create(:item) }
  let(:user) { FactoryGirl.create(:user) }
  subject { DestroyItem.call(item, user) }

  describe "#destroy" do

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
  end
end
