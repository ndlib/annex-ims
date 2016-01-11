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

  describe "#determine_batch_status" do
    let(:current_instance) { DestroyMatch.new(match1, user) }
    before(:each) do
      match1
      match2
      match3
    end

    it "returns continue batch when if there are remaining batches" do
      expect(current_instance.determine_batch_status).to eq "continue batch"
    end

    it "returns batch destroyed when there are no remaining batches" do
      match1.destroy!
      match2.destroy!
      match3.destroy!
      expect(current_instance.determine_batch_status).to eq "batch destroyed"
    end
  end

  describe "#remaining_matches" do
    let(:current_instance) { DestroyMatch.new(match1, user) }
    before(:each) do
      match1
      match2
      match3
    end

    it "returns true when there are remaining matches" do
      expect(current_instance.remaining_matches(match1.batch)).to be_truthy
    end

    it "returns false when there are no remaining matches" do
      match1.destroy!
      match2.destroy!
      match3.destroy!
      expect(current_instance.remaining_matches(match1.batch)).to be_falsey
    end
  end
end
