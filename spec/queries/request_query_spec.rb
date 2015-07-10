require "rails_helper"

RSpec.describe RequestQuery do
  let(:request) { FactoryGirl.create(:request, id: 1) }
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
    let(:subject) { RequestQuery.new }
    let(:request2) { FactoryGirl.create(:request, id: 2) }
    let(:request3) { FactoryGirl.create(:request, id: 3) }

    it "returns request for each id" do
      expect(subject.find_all_by_id(id_array: [1, 2])).to include(request, request2)
    end

    it "does not return other requests" do
      expect(subject.find_all_by_id(id_array: [1, 2])).not_to include(request3)
    end
  end
end
