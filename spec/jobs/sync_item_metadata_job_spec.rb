require "rails_helper"

RSpec.describe SyncItemMetadataJob, type: :job do
  let(:item) { instance_double(Item) }
  let(:user_id) { 1 }

  subject { described_class }

  describe "#perform" do
    it "calls SyncItemMetadata with set values" do
      expect(SyncItemMetadata).to receive(:call).with(item: item, user_id: user_id, background: true)
      subject.perform_now(item: item, user_id: user_id)
    end
  end
end
