require "rails_helper"

RSpec.describe SyncItemMetadata do
  let(:barcode) { "00000007819006" }
  let(:item) { FactoryGirl.create(:item, barcode: barcode) }
  let(:user) { FactoryGirl.create(:user) }
  let(:user_id) { user.id }

  context "self" do
    subject { described_class }

    describe "#call" do
      subject { described_class.call(item: item, user_id: user_id) }

      context "success" do
        before do
          stub_api_item_metadata(barcode: barcode)
        end

        it "updates the item metadata" do
          expect(subject).to eq(true)
          expect(item.title).to eq("The ubiquity of chaos / edited by Saul Krasner.")
          expect(item.author).to eq("Author")
          expect(item.chron).to eq("Description")
          expect(item.bib_number).to eq("000841979")
          expect(item.isbn_issn).to eq("0871683504")
          expect(item.conditions).to eq(["Condition"])
          expect(item.call_number).to eq("Q 172.5 .C45 U25 1990")
        end

        it "logs the activity" do
          expect(LogActivity).to receive(:call).with(anything, "UpdatedByAPI", anything, anything, anything).ordered
          expect(subject).to eq(true)
        end
      end

      context "error response" do
        let(:status_code) { 500 }

        before do
          stub_api_item_metadata(barcode: barcode, status_code: 500, body: {}.to_json)
        end

        shared_examples "an error response" do
          it "returns false" do
            expect(subject).to eq(false)
          end

          it "adds an issue" do
            expect(AddIssue).to receive(:call).with(user.id, barcode, anything).and_call_original
            subject
          end

          it "destroys the item" do
            expect(item).to receive(:destroy!)
            subject
          end

          it "logs the activity" do
            expect(LogActivity).to receive(:call).with(anything, "Destroyed", anything, anything, anything).ordered
            subject
          end
        end

        context "500 error" do
          let(:status_code) { 500 }

          it_behaves_like "an error response"
        end

        context "not found error" do
          let(:status_code) { 404 }

          it_behaves_like "an error response"
        end

        context "timeout error" do
          let(:status_code) { 599 }

          it_behaves_like "an error response"
        end

        context "unauthorized error" do
          let(:status_code) { 401 }

          it_behaves_like "an error response"
        end
      end
    end
  end
end
