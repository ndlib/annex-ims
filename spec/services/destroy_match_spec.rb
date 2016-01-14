require "rails_helper"

RSpec.describe DestroyMatch do
  let(:shelf) { FactoryGirl.create(:shelf) }
  let(:tray) { FactoryGirl.create(:tray, shelf: shelf) }
  let(:item) { FactoryGirl.create(:item, tray: tray, thickness: 1) }
  let(:bin) { FactoryGirl.create(:bin, items: [item]) }
  let(:match) { FactoryGirl.create(:match, item: item, bin: bin, request: request) }
  let(:batch) { FactoryGirl.create(:batch, user: user) }
  let(:match1) { FactoryGirl.create(:match, batch: batch) }
  let(:match2) { FactoryGirl.create(:match, batch: batch) }
  let(:match3) { FactoryGirl.create(:match, batch: batch) }
  let(:user) { FactoryGirl.create(:user) }
  let(:request) { FactoryGirl.create(:request, del_type: "loan") }

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
