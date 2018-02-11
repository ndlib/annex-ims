require 'rails_helper'

feature "Update", type: :feature do
  include AuthenticationHelper

  let(:item) { FactoryGirl.create(:item) }
  let(:new_item) { FactoryGirl.create(:item) }

  describe "as an admin" do
    before(:each) do
      login_admin
      visit root_path
    end

    it "can see Update Barcode in the menu" do
      click_link "Items"
      expect(page).to have_content "Update Barcode"
    end

    it "can access the Update Barcode page" do
      click_link "Items"
      click_link "Update Barcode"
      expect(current_path).to eq(update_path)
    end

    it "has the correct verbiage on the page" do
      click_link "Items"
      click_link "Update Barcode"
      expect(page).to have_content "Barcodes must have been updated in catalog the previous day"
    end

    it "has the old barcode form" do
      click_link "Items"
      click_link "Update Barcode"
      expect(page).to have_content "Old Barcode"
    end

    it "can find an item with the old barcode" do
      item
      click_link "Items"
      click_link "Update Barcode"
      fill_in "Old Barcode", with: item.barcode
      click_button "Save"
      expect(page).to have_content item.bib_number
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
      expect(page).to have_content item.isbn_issn
    end   

    it "can find an item with the new barcode" do
      item
      new_item
      click_link "Items"
      click_link "Update Barcode"
      fill_in "Old Barcode", with: item.barcode
      click_button "Save"
      fill_in "New Barcode", with: new_item.barcode
      click_button "Save"
      expect(page).to have_content new_item.bib_number
      expect(page).to have_content new_item.title
      expect(page).to have_content new_item.author
      expect(page).to have_content new_item.chron
      expect(page).to have_content new_item.isbn_issn
    end   

    it "clears data if you reject the new barcode" do
      item
      new_item
      click_link "Items"
      click_link "Update Barcode"
      fill_in "Old Barcode", with: item.barcode
      click_button "Save"
      fill_in "New Barcode", with: new_item.barcode
      click_button "Save"
      expect(page).to have_content new_item.bib_number
      click_link "CANCEL Barcode Update"
      expect(current_path).to eq(show_old_update_path)
    end   
  end

  describe "as a worker" do
    before(:each) do
      login_worker
      visit root_path
    end

    it "cannot see Update Barcode in the menu" do
      click_link "Items"
      expect(page).to_not have_content "Update Barcode"
    end
  end
end
