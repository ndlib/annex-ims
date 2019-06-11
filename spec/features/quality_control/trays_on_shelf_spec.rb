require 'rails_helper'

feature "Trays on Shelf", type: :feature do
  include AuthenticationHelper

  before(:all) do
    FactoryGirl.create(:tray_type)
  end

  let!(:shelf) { FactoryGirl.create(:shelf) }
  let!(:tray) { FactoryGirl.create(:tray, shelf: shelf) }
  let!(:bad_tray) { FactoryGirl.create(:tray) }
  let!(:item1) { FactoryGirl.create(:item, tray: tray) }
  let!(:item2) { FactoryGirl.create(:item, tray: tray) }

  describe "as an admin" do
    before(:each) do
      login_admin
      visit root_path
    end

    it "can see Trays on Shelf in the menu" do
      click_link "Quality Control"
      expect(page).to have_content "Trays on Shelf"
    end

    it "can access the Trays on Shelf page" do
      click_link "Quality Control"
      click_link "Trays on Shelf"
      expect(current_path).to eq(check_trays_new_path)
      expect(page).to have_content "Shelf Check Trays"
    end

    it "can accept a shelf barcode" do
      shelf
      visit check_trays_new_path
      fill_in "Shelf", with: shelf.barcode
      click_button "Submit"
      expect(current_path).to eq(check_trays_path)
    end

    it "rejects a non-shelf barcode" do
      visit check_trays_new_path
      fill_in "Shelf", with: "non-shelf"
      click_button "Submit"
      expect(current_path).to eq(check_trays_new_path)
      expect(page).to have_content "barcode is not a shelf"
    end

    it "lists a tray tied to a shelf" do
      shelf
      tray
      item1
      item2
      visit check_trays_new_path
      fill_in "Shelf", with: shelf.barcode
      click_button "Submit"
      expect(page).to have_content tray.barcode
      expect(page).to have_content tray.items.count
    end

    it "lists a count of trays associated with the shelf" do
      shelf
      tray
      visit check_trays_new_path
      fill_in "Shelf", with: shelf.barcode
      click_button "Submit"
      expect(page).to have_content "#{shelf.barcode}: 1 of #{shelf.capacity}"
    end

    it "connects to a tray qc page" do
      shelf
      tray
      item1
      item2
      visit check_trays_new_path
      fill_in "Shelf", with: shelf.barcode
      click_button "Submit"
      click_link tray.barcode
      expect(current_path).to eq(check_items_path(tray.barcode))
    end

    it "rejects non-tray barcodes" do
      shelf
      tray
      item1
      item2
      visit check_trays_new_path
      fill_in "Shelf", with: shelf.barcode
      click_button "Submit"
      fill_in "Tray", with: shelf.barcode
      click_button "Submit"
      expect(page).to have_content "Barcode \"#{shelf.barcode}\" is not valid, please re-scan."
    end

    it "rejects trays that don't exist" do
      shelf
      tray
      item1
      item2
      bad_barcode = tray.barcode + "1"
      visit check_trays_new_path
      fill_in "Shelf", with: shelf.barcode
      click_button "Submit"
      fill_in "Tray", with: bad_barcode
      click_button "Submit"
      expect(page).to have_content "Barcode #{bad_barcode} not found. Put item with barcode #{bad_barcode} on problem shelf."
    end

    it "rejects trays that exist but are not supposed to be on the shelf" do
      shelf
      tray
      bad_tray
      item1
      item2
      visit check_trays_new_path
      fill_in "Shelf", with: shelf.barcode
      click_button "Submit"
      fill_in "Tray", with: bad_tray.barcode
      click_button "Submit"
      expect(page).to have_content "Barcode #{bad_tray.barcode} is not associated to this shelf. Put tray with barcode #{bad_tray.barcode} on problem shelf."
    end
  end
end
