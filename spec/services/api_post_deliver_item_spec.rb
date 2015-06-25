require "rails_helper"

RSpec.describe ApiPostDeliverItem do
  let(:match) { FactoryGirl.create(:match, item: item) }
  let(:tray) { FactoryGirl.create(:tray) }
  let(:user) { FactoryGirl.create(:user) }
  let(:item) { FactoryGirl.create(:item, tray: tray) }

  context "self" do
    subject { described_class }

    describe "#call" do
      subject { described_class.call(match.id, user) }

      it "retrieves data" do
        stub_api_scan_send(match: match)
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.success?).to eq(true)
        expect(subject.body).to eq("status" => "OK", "message" => "Item status updated")
      end

      it "does not raise an exception on API failure" do
        stub_api_scan_send(match: match, status_code: 500, body: {}.to_json)
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.error?).to eq(true)
        expect(subject.body).to be_a_kind_of(Hash)
        expect(subject.body[:title]).to be_nil
      end
    end
  end
end
