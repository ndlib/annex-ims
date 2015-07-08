require 'rails_helper'

RSpec.describe IsPartOfSet do

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
  subject { IsPartOfSet }

  context "is part of set" do
    describe "::call" do
      it "should return true" do
        expect(subject.call(match_1)).to be_truthy 
      end
    end
  end

  context "is not part of set" do
    describe "::call" do
      it "should return false" do
        expect(subject.call(match_4)).to be_falsey 
      end
    end
  end

end
