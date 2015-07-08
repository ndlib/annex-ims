require "rails_helper"

RSpec.describe GetMatchSet do
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
  subject { GetMatchSet }

  context "when set includes three items" do
    describe "::call" do

      it "returns three entries" do
        expect(subject.call(match_1).count).to eq 3
      end

      it "has the appropriate ordinal text" do
        expect(subject.call(match_1)[item_1.id]).to eq "1st"
        expect(subject.call(match_1)[item_2.id]).to eq "2nd"
        expect(subject.call(match_1)[item_3.id]).to eq "3rd"
      end
    end
  end

  context "when set includes one item" do
    describe "::call" do

      it "returns one entry" do
        expect(subject.call(match_4).count).to eq 1
      end

      it "has the appropriate ordinal text" do
        expect(subject.call(match_4)[item_1.id]).to eq "1st"
      end
    end
  end
end
