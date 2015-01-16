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

    it "can search for an item by call number" do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      select("Call Number", :from => "criteria_type")
      fill_in "criteria", :with => @item.call_number
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
    end

    it "can search for an item by isbn" do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      select("ISBN", :from => "criteria_type")
      fill_in "criteria", :with => @item.isbn
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
    end

    it "can search for an item by issn" do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      select("ISSN", :from => "criteria_type")
      fill_in "criteria", :with => @item.issn
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
    end

    it "can search for an item by title" do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      select("Title", :from => "criteria_type")
      fill_in "criteria", :with => @item.title
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
    end

    it "can search for an item by author" do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      select("Author", :from => "criteria_type")
      fill_in "criteria", :with => @item.author
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
    end

    it "can search for an item by tray" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON', tray: @tray)
      visit search_path
      select("Tray", :from => "criteria_type")
      fill_in "criteria", :with => @tray.barcode
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
    end

    it "can search for an item by shelf" do
      @shelf = FactoryGirl.create(:shelf)
      @tray = FactoryGirl.create(:tray, shelf: @shelf)
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON', tray: @tray)
      visit search_path
      select("Shelf", :from => "criteria_type")
      fill_in "criteria", :with => @shelf.barcode
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
    end

    it "can search for items by condition" do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      find(:css, "#condition_bool_any").set(true)
      find(:css, "#conditions_#{@item.conditions.sample}").set(true)
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
    end

    it "can search for items by mutliple condition" do
      @item = FactoryGirl.create(:item, author: 'JOHN DOE', title: 'SOME TITLE', chron: 'TEST CHRN', conditions: ["COVER-TORN","COVER-DET"])
      @item2 = FactoryGirl.create(:item, author: 'BOB SMITH', title: 'SOME OTHER TITLE', chron: 'TEST CHRON 2', conditions: ["COVER-TORN","PAGES-DET"])
      visit search_path
      find(:css, "#condition_bool_all").set(true)
      find(:css, "#conditions_#{@item.conditions[0]}").set(true)
      find(:css, "#conditions_#{@item.conditions[1]}").set(true)
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
      expect(page).to_not have_content @item2.title
      expect(page).to_not have_content @item2.author
      expect(page).to_not have_content @item2.chron
    end

  end
end
