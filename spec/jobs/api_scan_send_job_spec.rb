require "rails_helper"

RSpec.describe ApiScanSendJob, type: :job do
  let(:match) { instance_double(Match) }

  subject { described_class }

  describe "#perform" do
    it "calls ApiPostDeliverItem with set values" do
      expect(ApiPostDeliverItem).to receive(:call).with(match: match)
      subject.perform_now(match: match)
    end
  end
end
