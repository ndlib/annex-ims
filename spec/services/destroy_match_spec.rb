require "rails_helper"

describe "DestroyMatch" do
  let(:user) { FactoryGirl.create(:user) }
  let(:batch) { FactoryGirl.create(:batch, user: user) }
  let(:match1) { FactoryGirl.create(:match, batch: batch) }
  let(:match2) { FactoryGirl.create(:match, batch: batch) }
  let(:match3) { FactoryGirl.create(:match, batch: batch) }
  let(:subject) { DestroyMatch.call(match1, user) }

  describe "#destroy" do
    before(:each) do
      match1
      match2
      match3
    end

    it "deletes one match" do
      expect(Match.all.count).to eq 3
      subject
      expect(Match.all.count).to eq 2
    end

    it "returns true on success" do
      expect(subject).to be_truthy
    end

    it "logs the activity" do
      expect(ActivityLogger).to receive(:remove_match).with(item: match1.item, request: match1.request, user: user).and_call_original
      subject
    end
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
