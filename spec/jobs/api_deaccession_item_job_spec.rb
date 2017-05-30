require "rails_helper"

RSpec.describe ApiDeaccessionItemJob, type: :job do
  let(:item) { instance_double(Item) }

  subject { described_class }

  describe "#perform" do
    it "calls ApiPostDeaccessionItem with set values and does not reject" do
      expect(ApiPostDeaccessionItem).to receive(:call).with(item: item)
      subject.perform_now(item: item)
    end
  end
end
