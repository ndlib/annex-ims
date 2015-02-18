require 'rails_helper'

feature "Search", :type => :feature do
  describe "when signed in" do
    before(:each) do
      # signin_user @user
      # pending "add user sign in code"
    end

    it "can search for an item by barcode", :search => true do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      select("Barcode", :from => "criteria_type")
      fill_in "criteria", :with => @item.barcode
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
      @item.destroy!
    end

    it "can search for an item by bib number", :search => true do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      select("Bib Number", :from => "criteria_type")
      fill_in "criteria", :with => @item.bib_number
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
      @item.destroy!
    end

    it "can search for 2 items with the same bib number", :search => true do
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
      @item.destroy!
      @item2.destroy!
    end

    it "can search for an item by call number", :search => true do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      select("Call Number", :from => "criteria_type")
      fill_in "criteria", :with => @item.call_number
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
      @item.destroy!
    end

    it "can search for an item by isbn", :search => true do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      select("ISBN", :from => "criteria_type")
      fill_in "criteria", :with => @item.isbn
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
      @item.destroy!
    end

    it "can search for an item by issn", :search => true do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      select("ISSN", :from => "criteria_type")
      fill_in "criteria", :with => @item.issn
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
      @item.destroy!
    end

    it "can search for an item by title", :search => true do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      select("Title", :from => "criteria_type")
      fill_in "criteria", :with => @item.title
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
      @item.destroy!
    end

    it "can search for an item by author", :search => true do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      select("Author", :from => "criteria_type")
      fill_in "criteria", :with => @item.author
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
      @item.destroy!
    end

    it "can search for an item by tray", :search => true do
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
      @item.destroy!
    end

    it "can search for an item by shelf", :search => true do
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
      @item.destroy!
    end

    it "can search for items by condition", :search => true do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit search_path
      find(:css, "#condition_bool_any").set(true)
      find(:css, "#conditions_#{@item.conditions.sample}").set(true)
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
      @item.destroy!
    end

    it "can search for items by multiple conditions", :search => true do
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
      @item.destroy!
      @item2.destroy!
    end

    it "can search for items by initial ingest date", :search => true do
      @item = FactoryGirl.create(:item, author: 'JOHN DOE', title: 'SOME TITLE', chron: 'TEST CHRN', conditions: ["COVER-TORN","COVER-DET"], initial_ingest: 3.days.ago.strftime("%Y-%m-%d"))
      @item2 = FactoryGirl.create(:item, author: 'BOB SMITH', title: 'SOME OTHER TITLE', chron: 'TEST CHRON 2', conditions: ["COVER-TORN","PAGES-DET"], initial_ingest: 1.day.ago.strftime("%Y-%m-%d"))
      visit search_path
      select("Initial Ingest Date", :from => "date_type")
      fill_in "start", :with => 4.days.ago.strftime("%Y-%m-%d")
      fill_in "finish", :with => 2.days.ago.strftime("%Y-%m-%d")
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
      expect(page).to_not have_content @item2.title
      expect(page).to_not have_content @item2.author
      expect(page).to_not have_content @item2.chron
      @item.destroy!
      @item2.destroy!
    end

    it "can search for items by last ingest date", :search => true do
      @item = FactoryGirl.create(:item, author: 'JOHN DOE', title: 'SOME TITLE', chron: 'TEST CHRN', conditions: ["COVER-TORN","COVER-DET"], last_ingest: 3.days.ago.strftime("%Y-%m-%d"))
      @item2 = FactoryGirl.create(:item, author: 'BOB SMITH', title: 'SOME OTHER TITLE', chron: 'TEST CHRON 2', conditions: ["COVER-TORN","PAGES-DET"], last_ingest: 1.day.ago.strftime("%Y-%m-%d"))
      visit search_path
      select("Last Ingest Date", :from => "date_type")
      fill_in "start", :with => 4.days.ago.strftime("%Y-%m-%d")
      fill_in "finish", :with => 2.days.ago.strftime("%Y-%m-%d")
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
      expect(page).to_not have_content @item2.title
      expect(page).to_not have_content @item2.author
      expect(page).to_not have_content @item2.chron
      @item.destroy!
      @item2.destroy!
    end

    it "can search for items by request date", :search => true do
      @item = FactoryGirl.create(:item, author: 'JOHN DOE', title: 'SOME TITLE', chron: 'TEST CHRN', thickness: 1, conditions: ["COVER-TORN","COVER-DET"])
      @request = FactoryGirl.create(:request, criteria_type: 'barcode', criteria: @item.barcode, item: @item, requested: 3.days.ago.strftime("%Y-%m-%d"))
      @item.save!
      @item2 = FactoryGirl.create(:item, author: 'BOB SMITH', title: 'SOME OTHER TITLE', chron: 'TEST CHRON 2', thickness: 1, conditions: ["COVER-TORN","PAGES-DET"])
      @request2 = FactoryGirl.create(:request, criteria_type: 'barcode', criteria: @item2.barcode, item: @item2, requested: 1.day.ago.strftime("%Y-%m-%d"))
      @item2.save!
      visit search_path
      select("Request Date", :from => "date_type")
      fill_in "start", :with => 4.days.ago.strftime("%Y-%m-%d")
      fill_in "finish", :with => 2.days.ago.strftime("%Y-%m-%d")
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
      expect(page).to_not have_content @item2.title
      expect(page).to_not have_content @item2.author
      expect(page).to_not have_content @item2.chron
      @request.destroy!
      @request2.destroy!
      @item.destroy!
      @item2.destroy!
    end

  end
end
