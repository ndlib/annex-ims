require "rails_helper"

RSpec.describe ApiGetItemMetadata do
  let(:barcode) { "00000007819006" }
  let(:item) { instance_double(Item, barcode: barcode) }
  let(:response) { ApiResponse.new(status_code: 200, body: {}) }

  context "self" do
    subject { described_class }

    describe "#call" do
      before do
        allow(ActivityLogger).to receive(:api_get_item_metadata)
      end

      subject { described_class.call(item: item) }

      it "retrieves data" do
        stub_api_item_metadata(barcode: barcode)
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.success?).to eq(true)
        expect(subject.body).to be_a_kind_of(Hash)
        expect(subject.body[:title]).to eq("The ubiquity of chaos / edited by Saul Krasner.")
      end

      it "logs the activity" do
        expect(ApiHandler).to receive(:get).and_return(response)
        expect(ActivityLogger).to receive(:api_get_item_metadata).with(item: item, params: { barcode: barcode }, api_response: response)
        subject
      end

      it "does not raise an exception on API failure" do
        stub_api_item_metadata(barcode: barcode, status_code: 500, body: {}.to_json)
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.error?).to eq(true)
        expect(subject.body).to be_a_kind_of(Hash)
        expect(subject.body[:title]).to be_nil
      end

      context "background" do
        subject { described_class.call(item: item, background: true) }

        it "does not send connection options" do
          expect(ApiHandler).to receive(:get).with(action: anything, params: anything, connection_opts: {}).and_return(response)
          subject
        end
      end

      context "foreground" do
        subject { described_class.call(item: item, background: false) }
        let(:expected_connection_opts) { { timeout: 3, max_retries: 0 } }

        it "sends connection options" do
          expect(ApiHandler).to receive(:get).with(action: anything, params: anything, connection_opts: expected_connection_opts).and_return(response)
          subject
        end
      end
    end
  end
end
