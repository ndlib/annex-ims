require "rails_helper"

RSpec.describe ActivityLogger do
  let(:item) { FactoryGirl.create(:item) }
  let(:bin) { FactoryGirl.create(:bin) }
  let(:tray) { FactoryGirl.create(:tray) }
  let(:shelf) { FactoryGirl.create(:shelf) }
  let(:user) { FactoryGirl.create(:user) }
  let(:issue) { FactoryGirl.create(:issue) }
  let(:request) { FactoryGirl.create(:request) }
  let(:api_response) { ApiResponse.new(status_code: 200, body: { status: "OK" }) }

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

  context "ApiRemoveRequest" do
    let(:arguments) { { request: request, params: { test: "test" }, api_response: api_response } }
    subject { described_class.api_remove_request(**arguments) }

    it_behaves_like "an activity log", "ApiRemoveRequest"
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

  context "CreatedIssue" do
    let(:arguments) { { issue: issue, item: item } }
    subject { described_class.create_issue(**arguments) }

    it_behaves_like "an activity log", "CreatedIssue"
  end

  context "CreatedItem" do
    let(:arguments) { { item: item, user: user } }
    subject { described_class.create_item(**arguments) }

    it_behaves_like "an activity log", "CreatedItem"
  end

  context "DestroyedItem" do
    let(:arguments) { { item: item, user: user } }
    subject { described_class.destroy_item(**arguments) }

    it_behaves_like "an activity log", "DestroyedItem"
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

  context "RemovedRequest" do
    let(:arguments) { { request: request, user: user } }
    subject { described_class.remove_request(**arguments) }

    it_behaves_like "an activity log", "RemovedRequest"
  end

  context "ScannedItem" do
    let(:arguments) { { item: item, request: request, user: user } }
    subject { described_class.scan_item(**arguments) }

    it_behaves_like "an activity log", "ScannedItem"
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

  context "UpdatedItemMetadata" do
    let(:arguments) { { item: item } }
    subject { described_class.update_item_metadata(**arguments) }

    it_behaves_like "an activity log", "UpdatedItemMetadata"
  end
end
