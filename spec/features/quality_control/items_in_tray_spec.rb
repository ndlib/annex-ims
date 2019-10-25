require 'rails_helper'

feature "Items in Tray", type: :feature do
  include AuthenticationHelper

  before(:all) do
    FactoryBot.create(:tray_type)
  end

  let!(:tray) { FactoryBot.create(:tray) }
  let!(:item) { FactoryBot.create(:item, tray: tray) }
  let!(:bad_item) { FactoryBot.create(:item) }
  let!(:bad_item_2) { FactoryBot.create(:item) }

  describe "as an admin" do
    before(:each) do
      login_admin
      visit root_path
    end

    it "adds to errors when scanning a tray" do
      tray
      item
      bad_item
      bad_item_2
      visit check_items_new_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      fill_in "Item", with: bad_item.barcode
      click_button "Save"
      expect(page).to have_content "Barcode #{bad_item.barcode} is not associated to this tray. Put item with barcode #{bad_item.barcode} on problem shelf."
      fill_in "Item", with: item.barcode
      click_button "Save"
      expect(page).to have_content "Barcode #{bad_item.barcode} is not associated to this tray. Put item with barcode #{bad_item.barcode} on problem shelf."
      fill_in "Item", with: bad_item_2.barcode
      click_button "Save"
      expect(page).to have_content "Barcode #{bad_item.barcode} is not associated to this tray. Put item with barcode #{bad_item.barcode} on problem shelf."
      expect(page).to have_content "Barcode #{bad_item_2.barcode} is not associated to this tray. Put item with barcode #{bad_item_2.barcode} on problem shelf."
    end
  end
end
