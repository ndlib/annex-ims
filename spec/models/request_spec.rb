require "rails_helper"

RSpec.describe "Request" do
  let(:request) { FactoryGirl.create(:request) }

  describe "#bin_type" do
    context "when source is aleph" do
      it "returns the correct bin type" do
        expect(request.bin_type).to eq "ALEPH-LOAN"
      end
    end

    context "when source is not aleph" do
      before(:each) do
        request.source = "ill"
      end

      context "when del_type is not loan" do
        before(:each) do
          request.del_type = "not loan"
        end

        it "returns the correct bin type" do
          expect(request.bin_type).to eq "ILL-SCAN"
        end
      end

      context "when del_type is loan" do
        it "returns the correct bin type" do
          expect(request.bin_type).to eq "ILL-LOAN"
        end
      end
    end

    context "#remaining_matches" do
      it "does not exclude accepted matches" do
        match = FactoryGirl.create(:match, request: request, processed: "accepted")
        expect(request.remaining_matches.count).to eq(1)
      end

      it "does not exclude new matches (where processed is nil)" do
        match = FactoryGirl.create(:match, request: request)
        expect(request.remaining_matches.count).to eq(1)
      end

      it "excludes skipped matches" do
        match = FactoryGirl.create(:match, request: request, processed: "skipped")
        expect(request.remaining_matches.count).to eq(0)
      end

      it "excludes completed matches" do
        match = FactoryGirl.create(:match, request: request, processed: "completed")
        expect(request.remaining_matches.count).to eq(0)
      end

      it "does not exclude any matches in some other processed status" do
        match = FactoryGirl.create(:match, request: request, processed: "some_new_thing")
        expect(request.remaining_matches.count).to eq(1)
      end
    end
  end
end
