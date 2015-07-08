require "rails_helper"

RSpec.describe MatchQuery do
  let!(:item_1) { FactoryGirl.create(:item) }
  let!(:item_2) { FactoryGirl.create(:item) }
  let!(:item_3) { FactoryGirl.create(:item) }
  let!(:batch) { FactoryGirl.create(:batch) }
  let!(:request_1) { FactoryGirl.create(:request) }
  let!(:request_2) { FactoryGirl.create(:request) }
  let!(:match_1) { FactoryGirl.create(:match, batch: batch, request: request_1, item: item_1) }
  let!(:match_2) { FactoryGirl.create(:match, batch: batch, request: request_1, item: item_2) }
  let!(:match_3) { FactoryGirl.create(:match, batch: batch, request: request_1, item: item_3) }
  let!(:match_4) { FactoryGirl.create(:match, batch: batch, request: request_2, item: item_1) }
  let(:relation) { Match.all }
  subject { MatchQuery.new(relation) }

  describe "#retrieve_set" do
    context "when retrieve_set includes three items" do
      it "returns three entries" do
        expect(subject.retrieve_set(match_1).count).to eq 3
      end

      it "has the appropriate ordinal text" do
        expect(subject.retrieve_set(match_1)[item_1.id]).to eq "1st"
        expect(subject.retrieve_set(match_1)[item_2.id]).to eq "2nd"
        expect(subject.retrieve_set(match_1)[item_3.id]).to eq "3rd"
      end
    end

    context "when set includes one item" do
      it "returns one entry" do
        expect(subject.retrieve_set(match_4).count).to eq 1
      end

      it "has the appropriate ordinal text" do
        expect(subject.retrieve_set(match_4)[item_1.id]).to eq "1st"
      end
    end
  end

  describe "#part_of_set?" do
    context "is part of set" do
      it "should return true" do
        expect(subject.part_of_set?(match_1)).to be_truthy
      end
    end

    context "is not part of set" do
      it "should return false" do
        expect(subject.part_of_set?(match_4)).to be_falsey
      end
    end
  end
end