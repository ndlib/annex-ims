require "rails_helper"

RSpec.describe ApiGetItemMetadata do
  let(:barcode) { "00000007819006" }

  context "self" do
    subject { described_class }

    describe "#call" do
      subject { described_class.call(barcode: barcode) }

      it "retrieves data" do
        stub_api_item_metadata(barcode: barcode)
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.success?).to eq(true)
        expect(subject.body).to be_a_kind_of(Hash)
        expect(subject.body[:title]).to eq("The ubiquity of chaos / edited by Saul Krasner.")
      end

      it "does not raise an exception on API failure" do
        stub_api_item_metadata(barcode: barcode, status_code: 500, body: {}.to_json)
        expect(subject).to be_a_kind_of(ApiResponse)
        expect(subject.error?).to eq(true)
        expect(subject.body).to be_a_kind_of(Hash)
        expect(subject.body[:title]).to be_nil
      end

      context "background" do
        subject { described_class.call(barcode: barcode, background: true) }

        it "does not send connection options" do
          expect(ApiHandler).to receive(:get).with(action: anything, params: anything, connection_opts: {})
          subject
        end
      end

      context "foreground" do
        subject { described_class.call(barcode: barcode, background: false) }
        let(:expected_connection_opts) { { timeout: 3, max_retries: 0 } }

        it "sends connection options" do
          expect(ApiHandler).to receive(:get).with(action: anything, params: anything, connection_opts: expected_connection_opts)
          subject
        end
      end
    end
  end
end
