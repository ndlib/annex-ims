require "rails_helper"

RSpec.describe ActivityLogger do
  let(:item) { FactoryGirl.create(:item) }
  let(:bin) { FactoryGirl.create(:bin) }
  let(:tray) { FactoryGirl.create(:tray) }
  let(:shelf) { FactoryGirl.create(:shelf) }
  let(:user) { FactoryGirl.create(:user) }
  let(:issue) { FactoryGirl.create(:issue) }
  let(:tray_issue) { FactoryGirl.create(:tray_issue) }
  let(:request) { FactoryGirl.create(:request) }
  let(:transfer) { FactoryGirl.create(:transfer) }
  let(:api_response) { ApiResponse.new(status_code: 200, body: { status: "OK" }) }
  let(:disposition) { FactoryGirl.create(:disposition) }
  let(:comment) { { comment: "A deaccessioning comment." } }

  shared_examples "an activity log" do |message|
    def compare_user(activity_log, user)
      if user
        expect(activity_log.username).to eq(user.username)
        expect(activity_log.user_id).to eq(user.id)
      else
        expect(activity_log.username).to be_nil
        expect(activity_log.user_id).to be_nil
      end
    end

    def data_object_value(object)
      if object.is_a?(Hash)
        data = object
      else
        data = object.attributes
      end
      JSON.parse(data.to_json)
    end

    it "sets the correct message and data" do
      expect(subject.action).to eq(message)
      arguments.each do |key, object|
        if key == :user
          compare_user(subject, object)
        else
          expect(subject.data[key.to_s]).to eq(data_object_value(object))
        end
      end
    end
  end

  context "AcceptedItem" do
    let(:arguments) { { item: item, user: user, request: request } }
    subject { described_class.accept_item(**arguments) }

    it_behaves_like "an activity log", "AcceptedItem"
  end

  context "ApiGetItemMetadata" do
    let(:arguments) do
      {
        item: item,
        params: { barcode: "1234" },
        api_response: api_response,
      }
    end
    subject { described_class.api_get_item_metadata(**arguments) }

    it_behaves_like "an activity log", "ApiGetItemMetadata"
  end

  context "ApiGetRequestList" do
    let(:arguments) { { api_response: api_response } }
    subject { described_class.api_get_request_list(**arguments) }

    it_behaves_like "an activity log", "ApiGetRequestList"
  end

  context "ApiStockItem" do
    let(:arguments) { { item: item, params: { test: "test" }, api_response: api_response } }
    subject { described_class.api_stock_item(**arguments) }

    it_behaves_like "an activity log", "ApiStockItem"
  end

  context "ApiDeaccessionItem" do
    let(:arguments) { { item: item, params: { test: "test" }, api_response: api_response } }
    subject { described_class.api_deaccession_item(**arguments) }

    it_behaves_like "an activity log", "ApiDeaccessionItem"
  end

  context "ApiRemoveRequest" do
    let(:arguments) { { request: request, params: { test: "test" }, api_response: api_response } }
    subject { described_class.api_remove_request(**arguments) }

    it_behaves_like "an activity log", "ApiRemoveRequest"
  end

  context "ApiScanItem" do
    let(:arguments) { { item: item, params: { test: "test" }, api_response: api_response } }
    subject { described_class.api_scan_item(**arguments) }

    it_behaves_like "an activity log", "ApiScanItem"
  end

  context "ApiSendItem" do
    let(:arguments) { { item: item, params: { test: "test" }, api_response: api_response } }
    subject { described_class.api_send_item(**arguments) }

    it_behaves_like "an activity log", "ApiSendItem"
  end

  context "AssociatedItemAndBin" do
    let(:arguments) { { item: item, bin: bin, user: user } }
    subject { described_class.associate_item_and_bin(**arguments) }

    it_behaves_like "an activity log", "AssociatedItemAndBin"
  end

  context "AssociatedItemAndTray" do
    let(:arguments) { { item: item, tray: tray, user: user } }
    subject { described_class.associate_item_and_tray(**arguments) }

    it_behaves_like "an activity log", "AssociatedItemAndTray"
  end

  context "AssociatedTrayAndShelf" do
    let(:arguments) { { shelf: shelf, tray: tray, user: user } }
    subject { described_class.associate_tray_and_shelf(**arguments) }

    it_behaves_like "an activity log", "AssociatedTrayAndShelf"
  end

  context "BatchedRequest" do
    let(:arguments) { { request: request, user: user } }
    subject { described_class.batch_request(**arguments) }

    it_behaves_like "an activity log", "BatchedRequest"
  end

  context "CreatedIssue" do
    let(:arguments) { { issue: issue, item: item, user: user } }
    subject { described_class.create_issue(**arguments) }

    it_behaves_like "an activity log", "CreatedIssue"
  end

  context "CreatedTrayIssue" do
    let(:arguments) { { issue: issue, tray: tray, user: user } }
    subject { described_class.create_tray_issue(**arguments) }

    it_behaves_like "an activity log", "CreatedTrayIssue"
  end

  context "CreatedItem" do
    let(:arguments) { { item: item, user: user } }
    subject { described_class.create_item(**arguments) }

    it_behaves_like "an activity log", "CreatedItem"
  end

  context "CreatedTransfer" do
    let(:arguments) { { shelf: shelf, transfer: transfer, user: user } }
    subject { described_class.create_transfer(**arguments) }

    it_behaves_like "an activity log", "CreatedTransfer"
  end

  context "DestroyedItem" do
    let(:arguments) { { item: item, user: user } }
    subject { described_class.destroy_item(**arguments) }

    it_behaves_like "an activity log", "DestroyedItem"
  end

  context "DestroyedTransfer" do
    let(:arguments) { { shelf: shelf, transfer: transfer, user: user } }
    subject { described_class.destroy_transfer(**arguments) }

    it_behaves_like "an activity log", "DestroyedTransfer"
  end

  context "DissociatedItemAndBin" do
    let(:arguments) { { item: item, bin: bin, user: user } }
    subject { described_class.dissociate_item_and_bin(**arguments) }

    it_behaves_like "an activity log", "DissociatedItemAndBin"
  end

  context "DissociatedItemAndTray" do
    let(:arguments) { { item: item, tray: tray, user: user } }
    subject { described_class.dissociate_item_and_tray(**arguments) }

    it_behaves_like "an activity log", "DissociatedItemAndTray"
  end

  context "DissociatedTrayAndShelf" do
    let(:arguments) { { shelf: shelf, tray: tray, user: user } }
    subject { described_class.dissociate_tray_and_shelf(**arguments) }

    it_behaves_like "an activity log", "DissociatedTrayAndShelf"
  end

  context "FilledRequest" do
    let(:arguments) { { request: request, user: user } }
    subject { described_class.fill_request(**arguments) }

    it_behaves_like "an activity log", "FilledRequest"
  end

  context "MatchedItem" do
    let(:arguments) { { item: item, request: request, user: user } }
    subject { described_class.match_item(**arguments) }

    it_behaves_like "an activity log", "MatchedItem"
  end

  context "ReceivedRequest" do
    let(:arguments) { { request: request } }
    subject { described_class.receive_request(**arguments) }

    it_behaves_like "an activity log", "ReceivedRequest"
  end

  context "RemovedMatch" do
    let(:arguments) { { item: item, request: request, user: user } }
    subject { described_class.remove_match(**arguments) }

    it_behaves_like "an activity log", "RemovedMatch"
  end

  context "RemovedRequest" do
    let(:arguments) { { request: request, user: user } }
    subject { described_class.remove_request(**arguments) }

    it_behaves_like "an activity log", "RemovedRequest"
  end

  context "ResolvedIssue" do
    let(:arguments) { { item: item, issue: issue, user: user } }
    subject { described_class.resolve_issue(**arguments) }

    it_behaves_like "an activity log", "ResolvedIssue"
  end

  context "ResolvedTrayIssue" do
    let(:arguments) { { tray: tray, issue: tray_issue, user: user } }
    subject { described_class.resolve_tray_issue(**arguments) }

    it_behaves_like "an activity log", "ResolvedTrayIssue"
  end

  context "ScannedItem" do
    let(:arguments) { { item: item, request: request, user: user } }
    subject { described_class.scan_item(**arguments) }

    it_behaves_like "an activity log", "ScannedItem"
  end

  context "SetItemDisposition" do
    let(:arguments) { { item: item, disposition: disposition } }
    subject { described_class.set_item_disposition(**arguments) }

    it_behaves_like "an activity log", "SetItemDisposition"
  end

  context "ShelvedTray" do
    let(:arguments) { { shelf: shelf, tray: tray, user: user } }
    subject { described_class.shelve_tray(**arguments) }

    it_behaves_like "an activity log", "ShelvedTray"
  end

  context "ShippedItem" do
    let(:arguments) { { item: item, request: request, user: user } }
    subject { described_class.ship_item(**arguments) }

    it_behaves_like "an activity log", "ShippedItem"
  end

  context "SkippedItem" do
    let(:arguments) { { item: item, request: request, user: user } }
    subject { described_class.skip_item(**arguments) }

    it_behaves_like "an activity log", "SkippedItem"
  end

  context "StockedItem" do
    let(:arguments) { { item: item, tray: tray, user: user } }
    subject { described_class.stock_item(**arguments) }

    it_behaves_like "an activity log", "StockedItem"
  end

  context "DeaccessionedItem" do
    let(:arguments) { { item: item, user: user, disposition: disposition, comment: comment } }
    subject { described_class.deaccession_item(**arguments) }

    it_behaves_like "an activity log", "DeaccessionedItem"
  end

  context "UnshelvedTray" do
    let(:arguments) { { shelf: shelf, tray: tray, user: user } }
    subject { described_class.unshelve_tray(**arguments) }

    it_behaves_like "an activity log", "UnshelvedTray"
  end

  context "UnstockedItem" do
    let(:arguments) { { item: item, tray: tray, user: user } }
    subject { described_class.unstock_item(**arguments) }

    it_behaves_like "an activity log", "UnstockedItem"
  end

  context "UpdatedBarcode" do
    let(:arguments) { { item: item, user: user } }
    subject { described_class.update_barcode(**arguments) }

    it_behaves_like "an activity log", "UpdatedBarcode"
  end

  context "UpdatedItemMetadata" do
    let(:arguments) { { item: item } }
    subject { described_class.update_item_metadata(**arguments) }

    it_behaves_like "an activity log", "UpdatedItemMetadata"
  end
end
