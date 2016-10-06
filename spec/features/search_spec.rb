require 'rails_helper'

feature "Search", :type => :feature, :search => true do
  include SolrSpecHelper
  include AuthenticationHelper

  describe "when signed in" do

    let(:shelf) { FactoryGirl.create(:shelf) }
    let(:tray) { FactoryGirl.create(:tray, barcode: 'TRAY-AH12345', shelf: shelf) }
    let(:tray2) { FactoryGirl.create(:tray, barcode: 'TRAY-BL6789', shelf: shelf) }

    let(:item) { FactoryGirl.create(:item,
                                    author: 'JOHN DOE',
                                    title: 'SOME TITLE',
                                    chron: 'TEST CHRN',
                                    bib_number: '12345',
                                    barcode: '9876543',
                                    isbn_issn: '987655432',
                                    call_number: 'A 123 .C654 1991',
                                    thickness: 1,
                                    tray: tray,
                                    initial_ingest: 3.days.ago.strftime("%Y-%m-%d"),
                                    last_ingest: 3.days.ago.strftime("%Y-%m-%d"),
                                    conditions: ["COVER-TORN","COVER-DET"]) }

    let(:item2) { FactoryGirl.create(:item,
                                    author: 'BUBBA SMITH',
                                    title: 'SOME OTHER TITLE',
                                    chron: 'TEST CHRN 2',
                                    bib_number: '12345',
                                    barcode: '4576839201',
                                    isbn_issn: '918273645',
                                    call_number: 'A 1234 .C654 1991',
                                    thickness: 1,
                                    tray: tray2,
                                    initial_ingest: 1.day.ago.strftime("%Y-%m-%d"),
                                    last_ingest: 1.day.ago.strftime("%Y-%m-%d"),
                                    conditions: ["COVER-TORN","PAGES-DET"])}

    let(:request1) { FactoryGirl.create(:request,
                                        criteria_type: 'barcode',
                                        criteria: item.barcode,
                                        requested: 3.days.ago.strftime("%Y-%m-%d")) }

    let(:request2) { FactoryGirl.create(:request,
                                        criteria_type: 'barcode',
                                        criteria: item2.barcode,
                                        requested: 1.day.ago.strftime("%Y-%m-%d")) }


    before(:all) do
      solr_setup
    end

    before(:each) do
      save_all
      login_admin
    end

    after(:all) do
      Item.remove_all_from_index!
    end

    it "can search for an item by barcode", :search => true do
      visit search_path
      select("Barcode", :from => "criteria_type")
      fill_in "criteria", :with => item.barcode
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
    end

    it "can search for an item by bib number", :search => true do
      visit search_path
      select("Bib Number", :from => "criteria_type")
      fill_in "criteria", :with => item.bib_number
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
    end

    it "can search for 2 items with the same bib number", :search => true do
      visit search_path
      select("Bib Number", :from => "criteria_type")
      fill_in "criteria", :with => item.bib_number
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
      expect(page).to have_content item2.title
      expect(page).to have_content item2.author
      expect(page).to have_content item2.chron
    end

    it "can search for an item by call number", :search => true do
      visit search_path
      select("Call Number", :from => "criteria_type")
      fill_in "criteria", :with => item.call_number
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
    end

    it "can search for an item by isbn/issn", :search => true do
      visit search_path
      select("ISBN/ISSN", :from => "criteria_type")
      fill_in "criteria", :with => item.isbn_issn
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
    end

    it "can search for an item by issn", :search => true do
      visit search_path
      select("ISSN", :from => "criteria_type")
      fill_in "criteria", :with => item.isbn_issn
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
    end

    it "can search for an item by title", :search => true do
      visit search_path
      select("Title", :from => "criteria_type")
      fill_in "criteria", :with => item.title
      find(:css, "#exact_match").set(true)
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
    end

    it "can search for an item by author", :search => true do
      visit search_path
      select("Author", :from => "criteria_type")
      fill_in "criteria", :with => item.author
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
    end

    it "can search for an item by tray", :search => true do
      visit search_path
      select("Tray", :from => "criteria_type")
      fill_in "criteria", :with => tray.barcode
      find(:css, "#exact_match").set(true)
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
    end

    it "can search for an item by shelf", :search => true do
      visit search_path
      select("Shelf", :from => "criteria_type")
      fill_in "criteria", :with => shelf.barcode
      find(:css, "#exact_match").set(true)
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
    end

    it "can search for items by condition", :search => true do
      item.index!
      Sunspot.commit
      visit search_path
      find(:css, "#condition_bool_any").set(true)
      find(:css, "#conditions_#{item.conditions.sample}").set(true)
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
    end

    it "can search for items by multiple conditions", :search => true do
      visit search_path
      find(:css, "#condition_bool_all").set(true)
      find(:css, "#conditions_#{item.conditions[0]}").set(true)
      find(:css, "#conditions_#{item.conditions[1]}").set(true)
      find(:css, "#exact_match").set(true)
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
      expect(page).to_not have_content item2.title
      expect(page).to_not have_content item2.author
      expect(page).to_not have_content item2.chron
    end

    it "can exclude specific conditions from search", :search => true do
      item.index!
      item2.index!
      Sunspot.commit
      Sunspot.commit
      visit search_path
      select("Tray", :from => "criteria_type")
      fill_in "criteria", :with => "TRAY"
      find(:css, "#condition_bool_none").set(true)
      find(:css, "#conditions_PAGES-DET").set(true)
      find(:css, "#exact_match").set(true)
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
    end

    it "can search for items by initial ingest date", :search => true do
      Sunspot.commit
      visit search_path
      select("Initial Ingest Date", :from => "date_type")
      fill_in "start", :with => 4.days.ago.strftime("%Y-%m-%d")
      fill_in "finish", :with => 2.days.ago.strftime("%Y-%m-%d")
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
      expect(page).to_not have_content item2.title
      expect(page).to_not have_content item2.author
      expect(page).to_not have_content item2.chron
    end

    it "can search for items by last ingest date", :search => true do
      item.index!
      item2.index!
      Sunspot.commit
      Sunspot.commit
      visit search_path
      select("Last Ingest Date", :from => "date_type")
      fill_in "start", :with => 4.days.ago.strftime("%Y-%m-%d")
      fill_in "finish", :with => 2.days.ago.strftime("%Y-%m-%d")
      click_button "Search"
      expect(current_path).to eq(search_path)
      expect(page).to have_content item.title
      expect(page).to have_content item.author
      expect(page).to have_content item.chron
      expect(page).to_not have_content item2.title
      expect(page).to_not have_content item2.author
      expect(page).to_not have_content item2.chron
    end

    # THIS IS CURRENTLY BROKEN BECAUSE OF THE DEPENDENCY ON THE MATCH TABLE
    # it "can search for items by request date", :search => true do
    #   item.index!
    #   item2.index!
    #   Sunspot.commit
    #   Sunspot.commit
    #   visit search_path
    #   select("Request Date", :from => "date_type")
    #   fill_in "start", :with => 4.days.ago.strftime("%Y-%m-%d")
    #   fill_in "finish", :with => 2.days.ago.strftime("%Y-%m-%d")
    #   click_button "Search"
    #   expect(current_path).to eq(search_path)
    #   expect(page).to have_content item.title
    #   expect(page).to have_content item.author
    #   expect(page).to have_content item.chron
    #   expect(page).to_not have_content item2.title
    #   expect(page).to_not have_content item2.author
    #   expect(page).to_not have_content item2.chron
    # end

    it "can download a csv of search results", :search => true do
      visit search_path
      select("Tray", :from => "criteria_type")
      fill_in "criteria", :with => tray.barcode
      find(:css, "#exact_match").set(true)
      click_button "Export"
      csv = CSV.parse(page.text)
      expect(csv.first).to eq [item.barcode, item.bib_number, item.isbn_issn, item.title, item.author, item.chron, item.tray.present? ? item.tray.barcode : '', item.shelf.present? ? item.shelf.barcode : '', item.conditions.join(", ")]
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
      item_updated2 = Item.find(item2.id)
      item_updated2.save!
      item_updated2.reload
      item_updated2.index!
      Sunspot.commit
    end

  end
end
