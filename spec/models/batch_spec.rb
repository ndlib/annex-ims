require "rails_helper"

RSpec.describe Batch do
  let(:batch) { FactoryGirl.create(:batch) }

  def create_item_with_tray_and_shelf(tray_barcode:, shelf_barcode:)
    shelf = Shelf.where(barcode: shelf_barcode).take || FactoryGirl.create(:shelf, barcode: shelf_barcode)
    tray = Tray.where(barcode: tray_barcode).take || FactoryGirl.create(:tray, barcode: tray_barcode, shelf: shelf)
    FactoryGirl.create(:item, tray: tray)
  end

  it "has a valid factory" do
    expect(batch).to be_valid
  end

  describe "#skipped_matches" do
    it "is matches that were skipped" do
      skipped_matches = FactoryGirl.create_list(:match, 2, processed: "skipped", batch: batch)
      other_match = FactoryGirl.create(:match, processed: nil, batch: batch)
      skipped_matches.each do |match|
        expect(batch.skipped_matches).to include(match)
      end
      expect(batch.skipped_matches).to_not include(other_match)
    end
  end

  describe "#unprocessed_matches_for_request" do
    let(:request) { FactoryGirl.create(:request, del_type: "loan") }

    it "is unprocessed matches for the request" do
      matches = FactoryGirl.create_list(:match, 2, processed: nil, batch: batch, request: request)
      other_match = FactoryGirl.create(:match, processed: "accepted", batch: batch, request: request)
      matches.each do |match|
        expect(batch.unprocessed_matches_for_request(request)).to include(match)
      end
      expect(batch.unprocessed_matches_for_request(request)).to_not include(other_match)
    end
  end

  describe "#current_match" do
    it "returns an unprocessed match for an item without a tray" do
      unassigned_item = FactoryGirl.create(:item, tray: nil)
      match = FactoryGirl.create(:match, processed: nil, batch: batch, item: unassigned_item)
      expect(batch.current_match).to eq(match)
    end

    it "orders matches by shelf" do
      first_item = create_item_with_tray_and_shelf(tray_barcode: "TRAY-AL1", shelf_barcode: "SHELF-1")
      second_item = create_item_with_tray_and_shelf(tray_barcode: "TRAY-AH1", shelf_barcode: "SHELF-2")
      second_match = FactoryGirl.create(:match, processed: nil, batch: batch, item: second_item)
      first_match = FactoryGirl.create(:match, processed: nil, batch: batch, item: first_item)
      expect(batch.current_match).to eq(first_match)
      first_match.update!(processed: "accepted")
      expect(batch.current_match).to eq(second_match)
    end
  end
end
