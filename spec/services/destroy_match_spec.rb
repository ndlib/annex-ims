require "rails_helper"

RSpec.describe DestroyMatch do
  let(:shelf) { FactoryBot.create(:shelf) }
  let(:tray) { FactoryBot.create(:tray, shelf: shelf) }
  let(:item) { FactoryBot.create(:item, tray: tray, thickness: 1) }
  let(:bin) { FactoryBot.create(:bin, items: [item]) }
  let(:match) { FactoryBot.create(:match, item: item, bin: bin, request: request) }
  let(:batch) { FactoryBot.create(:batch, user: user) }
  let(:match1) { FactoryBot.create(:match, batch: batch) }
  let(:match2) { FactoryBot.create(:match, batch: batch) }
  let(:match3) { FactoryBot.create(:match, batch: batch) }
  let(:user) { FactoryBot.create(:user) }
  let(:request) { FactoryBot.create(:request, del_type: "loan") }

  subject { described_class.call(match: match, user: user) }

  it "is truthy" do
    expect(subject).to be_truthy
  end

  it "logs a RemovedMatch activity" do
    expect(ActivityLogger).to receive(:remove_match)
    subject
  end

  it "destroys the match" do
    expect(match).to receive(:destroy!)
    subject
  end
end
