require "rails_helper"

RSpec.describe "Request" do
  let(:del_type) { "loan" }
  let(:request) { FactoryGirl.create(:request, del_type: del_type) }

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

      context "when del_type is scan" do
        let(:del_type) { "scan" }

        it "returns the correct bin type" do
          expect(request.bin_type).to eq "ILL-SCAN"
        end
      end

      context "when del_type is loan" do
        let(:del_type) { "loan" }

        it "returns the correct bin type" do
          expect(request.bin_type).to eq "ILL-LOAN"
        end
      end
    end
  end
end
