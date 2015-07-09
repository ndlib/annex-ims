require "rails_helper"

RSpec.describe RequestQuery do
  let(:request) { FactoryGirl.create(:request) }
  let(:subject) { RequestQuery.new(request) }

  context "#remaining_matches" do
    it "does not exclude accepted matches" do
      FactoryGirl.create(:match, request: request, processed: "accepted")
      expect(subject.remaining_matches.count).to eq(1)
    end

    it "does not exclude new matches (where processed is nil)" do
      FactoryGirl.create(:match, request: request)
      expect(subject.remaining_matches.count).to eq(1)
    end

    it "excludes skipped matches" do
      FactoryGirl.create(:match, request: request, processed: "skipped")
      expect(subject.remaining_matches.count).to eq(0)
    end

    it "excludes completed matches" do
      FactoryGirl.create(:match, request: request, processed: "completed")
      expect(subject.remaining_matches.count).to eq(0)
    end

    it "does not exclude any matches in some other processed status" do
      FactoryGirl.create(:match, request: request, processed: "some_new_thing")
      expect(subject.remaining_matches.count).to eq(1)
    end
  end

  context "#find_all_by_id" do
    it "returns request for each id"
    it "does not return other requests"
  end
end
