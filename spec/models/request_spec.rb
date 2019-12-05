require "rails_helper"

RSpec.describe "Request" do
  let(:request) { FactoryBot.create(:request) }

  describe "#bin_type" do
    context "when source is aleph" do
      it "returns the correct bin type" do
        expect(request.bin_type).to eq "ALEPH-LOAN"
      end
    end

    context "when source is illiad" do
      before(:each) do
        request.source = "illiad"
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

    context "when source is deaccessioning" do
      before(:each) do
        request.source = "deaccessioning"
      end

      it "returns the correct bin type" do
        expect(request.bin_type). to eq "REM-STOCK"
      end
    end
  end
end
