require 'rails_helper'

feature "Items", :type => :feature do
  describe "when signed in" do
    before(:each) do
      # signin_user @user
      # pending "add user sign in code"
    end

    it "can scan a new item" do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit items_path
      fill_in "Item", :with => @item.barcode
      click_button "Find"
      expect(current_path).to eq(show_item_path(:id => @item.id))
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
    end

    it "can scan an item and then scan another item to change tasks" do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      @item2 = FactoryGirl.create(:item, chron: 'TEST CHRON 2')
      visit items_path
      fill_in "Item", :with => @item.barcode
      click_button "Find"
      expect(current_path).to eq(show_item_path(:id => @item.id))
      fill_in "Item", :with => @item2.barcode
      click_button "Scan"
      expect(current_path).to eq(show_item_path(:id => @item2.id))
      expect(page).to have_content @item2.title
      expect(page).to have_content @item2.author
      expect(page).to have_content @item2.chron
    end

    it "can scan an item and then scan a tray to stock it" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON', tray: @tray)
      visit items_path
      fill_in "Item", :with => @item.barcode
      click_button "Find"
      expect(current_path).to eq(show_item_path(:id => @item.id))
      fill_in "Tray", :with => @tray.barcode
      click_button "Scan"
      expect(current_path).to eq(items_path)
      expect(page).to have_content "Item #{@item.barcode} stocked."
    end

    it "can scan an item and then scan a tray and show an error for the wrong tray" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON', tray: @tray)
      @tray2 = FactoryGirl.create(:tray)
      visit items_path
      fill_in "Item", :with => @item.barcode
      click_button "Find"
      expect(current_path).to eq(show_item_path(:id => @item.id))
      fill_in "Tray", :with => @tray2.barcode
      click_button "Scan"
      expect(current_path).to eq(show_item_path(:id => @item.id))
      expect(page).to have_content 'incorrect tray for this item'
    end

  end
end
