require "rails_helper"

RSpec.describe BuildBatch, search: true do
  describe "when signed in" do

    let(:shelf) { FactoryGirl.create(:shelf) }
    let(:tray) { FactoryGirl.create(:tray, barcode: "TRAY-AH12346", shelf: shelf) }
    let(:tray2) { FactoryGirl.create(:tray, barcode: "TRAY-BL6788", shelf: shelf) }

    let(:item) { FactoryGirl.create(:item,
                                    author: "JOHN DOE",
                                    title: "SOME TITLE",
                                    chron: "TEST CHRN",
                                    bib_number: "12345",
                                    barcode: "9876542",
                                    isbn_issn: "987655432",
                                    call_number: "A 123 .C654 1991",
                                    thickness: 1,
                                    tray: tray,
                                    initial_ingest: 3.days.ago.strftime("%Y-%m-%d"),
                                    last_ingest: 3.days.ago.strftime("%Y-%m-%d"),
                                    conditions: ["COVER-TORN","COVER-DET"]) }

    let(:item2) { FactoryGirl.create(:item,
                                    author: "BUBBA SMITH",
                                    title: "SOME OTHER TITLE",
                                    chron: "TEST CHRN 2",
                                    bib_number: "12345",
                                    barcode: "4576839200",
                                    isbn_issn: "918273645",
                                    call_number: "A 1234 .C654 1991",
                                    thickness: 1,
                                    tray: tray2,
                                    initial_ingest: 1.day.ago.strftime("%Y-%m-%d"),
                                    last_ingest: 1.day.ago.strftime("%Y-%m-%d"),
                                    conditions: ["COVER-TORN","PAGES-DET"])}

    let(:request1) { FactoryGirl.create(:request,
                                        criteria_type: "barcode",
                                        criteria: item.barcode,
                                        requested: 3.days.ago.strftime("%Y-%m-%d")) }

    let(:request2) { FactoryGirl.create(:request,
                                        criteria_type: "barcode",
                                        criteria: item2.barcode,
                                        requested: 1.day.ago.strftime("%Y-%m-%d")) }

    let(:current_user) { FactoryGirl.create(:user) }

    before(:each) do
      save_all
    end

    after(:all) do
      Item.remove_all_from_index!
    end

    it "builds a batch when an item is selected", search: true do
      test = ["#{request1.id}-#{item.id}"]
      expected = {}
      result = BuildBatch.call(test, current_user)
      expect(request1).to eq result.requests[0]
      expect(item).to eq result.items[0]
    end

    def save_all
      shelf.save!
      tray.save!
      tray2.save!
      item.save!
      item.reload
      item.index!
      Sunspot.commit
      item2.save!
      item2.reload
      item2.index!
      Sunspot.commit
      request1.save!
      request2.save!
      item_updated = Item.find(item.id)
      item_updated.save!
      item_updated.reload
      item_updated.index!
      Sunspot.commit
    end

    it "logs a MatchedItem for each item in the batch" do
      test = ["#{request1.id}-#{item.id}", "#{request1.id}-#{item2.id}"]
      expect(ActivityLogger).to receive(:match_item).with(item: item, request: request1, user: current_user)
      expect(ActivityLogger).to receive(:match_item).with(item: item2, request: request1, user: current_user)
      described_class.call(test, current_user)
    end

    it "logs a BatchedRequest" do
      test = ["#{request1.id}-#{item.id}"]
      expect(ActivityLogger).to receive(:batch_request).with(request: request1, user: current_user)
      described_class.call(test, current_user)
    end

    it "only logs one BatchedRequest log for a Request with multiple items" do
      test = ["#{request1.id}-#{item.id}", "#{request1.id}-#{item2.id}"]
      expect(ActivityLogger).to receive(:batch_request).with(request: request1, user: current_user).once
      described_class.call(test, current_user)
    end

    it "logs one BatchedRequest log for a new Request but doesn't log for Requests that were previously added to the batch" do
      test = ["#{request2.id}-#{item.id}", "#{request2.id}-#{item2.id}"]
      expect(ActivityLogger).not_to receive(:batch_request).with(request: request1, user: current_user)
      expect(ActivityLogger).to receive(:batch_request).with(request: request2, user: current_user)
      described_class.call(test, current_user)
    end
  end
end
