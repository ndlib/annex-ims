require "rails_helper"

RSpec.describe GetItemFromMetadata do
  include ItemMetadata

  let(:barcode) { "00000007819006" }
  let(:user) { FactoryGirl.create(:user) }
  let(:user_id) { user.id }
  let(:response) { ApiResponse.new(status_code: 200, body: { sublibrary: "ANNEX" }) }

  context "self" do
    before(:each) do
      data = api_fixture_data('item_metadata.json')
      hash = JSON.parse(data)
      new_hash = map_item_attributes(hash.symbolize_keys)
      new_hash['barcode'] = barcode
      @new_item = Item.new(new_hash)
      @new_barcode = @new_item.barcode
      stub_api_item_metadata(barcode: @new_barcode)
    end

    subject { described_class }

    describe "#call" do
      subject { described_class.call(barcode: barcode, user_id: user_id) }

      shared_examples "a metadata status update" do |expected_status|
        it "sets the item metadata_status to #{expected_status}" do
          item = subject
          expect(item.metadata_status).to eq(expected_status)
        end

        it "updates the metadata_updated_at" do
          item = Item.new 
          expect(item.metadata_updated_at).to be_nil
          item = subject
          expect(item.metadata_updated_at).to be_present
          expect(Time.now - item.metadata_updated_at).to be < 1
        end
      end

      shared_examples "an issue logger" do |expected_issue_type|
        it "calls AddIssue with #{expected_issue_type}" do
          expect(AddIssue).to receive(:call).with(item: kind_of(Item), user: user, type: expected_issue_type)
          subject
        end
      end

      context "no user id" do
        subject { described_class.new(barcode: barcode, user_id: nil) }
        it "returns nil" do
          expect(subject.send(:user)).to be_nil
        end
      end

      context "success" do
        it "gets the item metadata" do
          item = subject
          expect(item.title).to eq("The ubiquity of chaos / edited by Saul Krasner.")
          expect(item.author).to eq("Author")
          expect(item.chron).to eq("Description")
          expect(item.bib_number).to eq("000841979")
          expect(item.isbn_issn).to eq("0871683504")
          expect(item.conditions).to eq(["Condition"])
          expect(item.call_number).to eq("Q 172.5 .C45 U25 1990")
        end

        it "logs the activity" do
          expect(ActivityLogger).to receive(:api_get_item_metadata)
          item = subject
          expect(item.to_json).to eql(@new_item.to_json)
        end
      end

      context "timeout" do
        before do
          stub_request(:get, api_item_metadata_url(barcode)).to_timeout
        end

        it "returns false and is a timeout response" do
          item = subject
          expect(item).to eq(nil)
        end
      end

      context "error response" do
        let(:body_json) { { sublibrary: "ANNEX" }.to_json }

        before do
          stub_api_item_metadata(barcode: barcode, status_code: status_code, body: body_json)
        end

        shared_examples "an error response" do
          it "returns nil" do
            expect(subject).to eq(nil)
          end
        end

        context "500 error" do
          let(:status_code) { 500 }

          it_behaves_like "an error response"
        end

        context "not found error" do
          let(:status_code) { 404 }

          it_behaves_like "an error response"

          it_behaves_like "an issue logger", "not_found"
        end

        context "timeout error" do
          let(:status_code) { 599 }

          it_behaves_like "an error response"
        end

        context "unauthorized error" do
          let(:status_code) { 401 }

          it_behaves_like "an error response"
        end

        context "no sublibrary code" do
          let(:body_json) { {}.to_json }
          let(:status_code) { 200 }

          it_behaves_like "an issue logger", "not_for_annex"
        end

        context "sublibrary code is not ANNEX" do
          let(:body_json) { { sublibrary: "SOMETHINGELSE" }.to_json }
          let(:status_code) { 200 }

          it_behaves_like "an issue logger", "not_for_annex"
        end
      end
    end
  end
end
