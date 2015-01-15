require 'rails_helper'

feature "Search", :type => :feature do
  describe "when signed in" do
    before(:each) do
      # signin_user @user
      # pending "add user sign in code"
    end

    it "can search for an item by barcode" do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      select("Barcode", :from => "criteria_type")
      fill_in "criteria", :with => @item.barcode
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
    end

    it "can search for an item by bib number" do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      select("Bib Number", :from => "criteria_type")
      fill_in "criteria", :with => @item.bib_number
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
    end

    it "can search for 2 items with the same bib number" do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      @item2 = FactoryGirl.create(:item, chron: 'TEST CHRON 2', bib_number: @item.bib_number)
      visit search_path
      select("Bib Number", :from => "criteria_type")
      fill_in "criteria", :with => @item.bib_number
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
      expect(page).to have_content @item2.title
      expect(page).to have_content @item2.author
      expect(page).to have_content @item2.chron
    end

  end
end
