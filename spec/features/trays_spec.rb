require 'rails_helper'

feature "Trays", :type => :feature do
  include AuthenticationHelper

  describe "when signed in" do
    before(:each) do
      login_user

      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item)
      @item2 = FactoryGirl.create(:item)

      template = Addressable::Template.new "#{Rails.application.secrets.api_server}/1.0/resources/items/record?auth_token=#{Rails.application.secrets.api_token}&barcode={barcode}"

      @template2 = Addressable::Template.new "#{Rails.application.secrets.api_server}/1.0/resources/items/stock?auth_token=#{Rails.application.secrets.api_token}"

      stub_request(:get, template). with(:headers => {'User-Agent'=>'Faraday v0.9.1'}). to_return{ |response| { :status => 200, :body => {"item_id" => "00110147500410", "barcode" => @item.barcode, "bib_id" => @item.bib_number, "sequence_number" => "00410", "admin_document_number" => "001101475", "call_number" => @item.call_number, "description" => @item.chron ,"title"=> @item.title, "author" => @item.author ,"publication" => "Cambridge, UK : Elsevier Science Publishers, c1991-", "edition" => "", "isbn_issn" =>@item.isbn_issn, "condition" => @item.conditions}.to_json, :headers => {} } }

      stub_request(:post, @template2).
        with(:body => {"barcode"=>"#{@item.barcode}", "item_id"=>"#{@item.id}", "tray_code"=>"#{@tray.barcode}"},
          :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.9.1'}).
        to_return{ |response| { :status => 200, :body => {:results => {:status => "OK", :message => "Item stocked"}}.to_json, :headers => {} } }

    end

    after(:each) do
      ActivityLog.all.each do |log|
        log.destroy!
      end
      Item.all.each do |item|
        item.destroy!
      end
      Tray.all.each do |tray|
        tray.destroy!
      end

    end

    it "can scan a new tray" do
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
    end

    it "runs through unassigned-unshelved-cancel flow" do
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      expect{page.find_by_id("pull")}.to raise_error
      expect{page.find_by_id("unassign")}.to raise_error
      click_button "Cancel"
      expect(current_path).to eq(trays_path)
    end

    it "runs through unassigned-unshelved-scan flow" do
      @shelf = FactoryGirl.create(:shelf)
      @tray = FactoryGirl.create(:tray, shelf: nil, shelved: false)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      expect{page.find_by_id("pull")}.to raise_error
      expect{page.find_by_id("unassign")}.to raise_error
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(trays_path)
    end

    it "runs through unassigned-unshelved-scan flow and check shelf size, allow same size" do
      @shelf = FactoryGirl.create(:shelf)
      @tray = FactoryGirl.create(:tray, shelf: nil, shelved: false)
      @tray2 = FactoryGirl.create(:tray, shelf: nil, shelved: false)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      expect{page.find_by_id("pull")}.to raise_error
      expect{page.find_by_id("unassign")}.to raise_error
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(trays_path)
      fill_in "Tray", :with => @tray2.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray2.id))
      expect(page).to have_content @tray2.barcode
      expect(page).to have_content "STAGING"
      expect{page.find_by_id("pull")}.to raise_error
      expect{page.find_by_id("unassign")}.to raise_error
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(trays_path)
    end

    it "runs through unassigned-unshelved-scan flow and check shelf size, reject different size" do
      @shelf = FactoryGirl.create(:shelf)
      @tray = FactoryGirl.create(:tray, shelf: nil, shelved: false, barcode: "TRAY-AL1234")
      @tray2 = FactoryGirl.create(:tray, shelf: nil, shelved: false, barcode: "TRAY-AH1234")
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      expect{page.find_by_id("pull")}.to raise_error
      expect{page.find_by_id("unassign")}.to raise_error
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(trays_path)
      fill_in "Tray", :with => @tray2.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray2.id))
      expect(page).to have_content @tray2.barcode
      expect(page).to have_content "STAGING"
      expect{page.find_by_id("pull")}.to raise_error
      expect{page.find_by_id("unassign")}.to raise_error
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(page).to have_content "tray sizes must match"
      expect(current_path).to eq(show_tray_path(:id => @tray2.id))
    end

    it "runs through unassigned-unshelved-scan flow and check shelf size, accept different size after removing one" do
      @shelf = FactoryGirl.create(:shelf)
      @tray = FactoryGirl.create(:tray, shelf: nil, shelved: false, barcode: "TRAY-AL1236")
      @tray2 = FactoryGirl.create(:tray, shelf: nil, shelved: false, barcode: "TRAY-AH1236")
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      expect{page.find_by_id("pull")}.to raise_error
      expect{page.find_by_id("unassign")}.to raise_error
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(trays_path)
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      click_button "Unassign"
      expect(current_path).to eq(trays_path)
      fill_in "Tray", :with => @tray2.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray2.id))
      expect(page).to have_content @tray2.barcode
      expect(page).to have_content "STAGING"
      expect{page.find_by_id("pull")}.to raise_error
      expect{page.find_by_id("unassign")}.to raise_error
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(trays_path)
    end

    it "runs through assigned-unshelved-cancel flow" do
      @shelf = FactoryGirl.create(:shelf)
      @tray = FactoryGirl.create(:tray, shelf: @shelf, shelved: false)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect{page.find_by_id("pull")}.to raise_error
      click_button "Cancel"
      expect(current_path).to eq(trays_path)
    end

    it "runs through assigned-unshelved-unassign flow" do
      @shelf = FactoryGirl.create(:shelf)
      @tray = FactoryGirl.create(:tray, shelf: @shelf, shelved: false)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect{page.find_by_id("pull")}.to raise_error
      click_button "Unassign"
      expect(current_path).to eq(trays_path)
    end

    it "runs through assigned-unshelved-scan-same flow" do
      @shelf = FactoryGirl.create(:shelf)
      @tray = FactoryGirl.create(:tray, shelf: @shelf, shelved: false)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect{page.find_by_id("pull")}.to raise_error
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(trays_path)
    end

    it "runs through assigned-unshelved-scan-different-shelve flow" do
      @shelf = FactoryGirl.create(:shelf)
      @shelf2 = FactoryGirl.create(:shelf, barcode: "SHELF-11111")
      @tray = FactoryGirl.create(:tray, shelf: @shelf, shelved: false)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect{page.find_by_id("pull")}.to raise_error
      fill_in "Shelf", :with => @shelf2.barcode
      click_button "Save"
      expect(current_path).to eq(wrong_shelf_path(:id => @tray.id))
      expect(page).to have_content "#{@tray.barcode} belongs to #{@shelf.barcode}, but #{@shelf2.barcode} was scanned."
      click_button "Shelve Anyway"
      expect(current_path).to eq(trays_path)
    end

    it "runs through assigned-unshelved-scan-different flow-cancel" do
      @shelf = FactoryGirl.create(:shelf)
      @shelf2 = FactoryGirl.create(:shelf, barcode: "SHELF-11112")
      @tray = FactoryGirl.create(:tray, shelf: @shelf, shelved: false)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect{page.find_by_id("pull")}.to raise_error
      fill_in "Shelf", :with => @shelf2.barcode
      click_button "Save"
      expect(current_path).to eq(wrong_shelf_path(:id => @tray.id))
      expect(page).to have_content "#{@tray.barcode} belongs to #{@shelf.barcode}, but #{@shelf2.barcode} was scanned."
      click_button "Cancel"
      expect(current_path).to eq(trays_path)
    end

    it "runs through assigned-shelved-cancel flow" do
      @shelf = FactoryGirl.create(:shelf)
      @tray = FactoryGirl.create(:tray, shelf: @shelf, shelved: true)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect{page.find_by_id("barcode")}.to raise_error
      click_button "Cancel"
      expect(current_path).to eq(trays_path)
    end

    it "runs through assigned-shelved-unassign flow" do
      @shelf = FactoryGirl.create(:shelf)
      @tray = FactoryGirl.create(:tray, shelf: @shelf, shelved: true)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect{page.find_by_id("barcode")}.to raise_error
      click_button "Unassign"
      expect(current_path).to eq(trays_path)

    end

    it "runs through assigned-shelved-pull flow" do
      @shelf = FactoryGirl.create(:shelf)
      @tray = FactoryGirl.create(:tray, shelf: @shelf, shelved: true)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect{page.find_by_id("barcode")}.to raise_error
      click_button "Pull"
      expect(current_path).to eq(trays_path)
    end

    it "can scan a new tray for processing items" do
      @tray = FactoryGirl.create(:tray)
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
    end

    it "can scan an item for adding to a tray" do
      @tray = FactoryGirl.create(:tray)
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
    end

    it "can select a width for an item" do
      @tray = FactoryGirl.create(:tray)
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      fill_in "Thickness", :with => Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
    end

    it "requires a width for an item" do
      @tray = FactoryGirl.create(:tray)
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content 'select a valid thickness'
    end

    it "displays an item after successfully adding it to a tray" do
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      fill_in "Thickness", :with => Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @item.barcode
      expect(page).to have_content @item.title
      expect(page).to have_content @item.thickness
      expect(page).to have_content @item.chron
    end

   it "displays information about a successful association made" do
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      fill_in "Thickness", :with => Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @item.barcode
      expect(page).to have_content @item.title
      expect(page).to have_content @item.thickness
      expect(page).to have_content @item.chron
      expect(page).to have_content "Item #{@item.barcode} stocked in #{@tray.barcode}."
   end

   it "accepts re-associating an item to the same tray" do
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      fill_in "Thickness", :with => Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @item.barcode
      expect(page).to have_content @item.title
      expect(page).to have_content @item.thickness
      expect(page).to have_content @item.chron
      expect(page).to have_content "Item #{@item.barcode} stocked in #{@tray.barcode}."
      fill_in "Item", :with => @item.barcode
      fill_in "Thickness", :with => Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @item.barcode
      expect(page).to have_content @item.title
      expect(page).to have_content @item.thickness
      expect(page).to have_content @item.chron
      expect(page).to have_content "Item #{@item.barcode} already assigned to #{@tray.barcode}. Record updated."
   end


   it "rejects associating an item to the wrong tray" do
      @tray2 = FactoryGirl.create(:tray)
      stub_request(:post, @template2).
        with(:body => {"barcode"=>"#{@item.barcode}", "item_id"=>"#{@item.id}", "tray_code"=>"#{@tray2.barcode}"},
          :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.9.1'}).
        to_return{ |response| { :status => 200, :body => {:results => {:status => "OK", :message => "Item stocked"}}.to_json, :headers => {} } }
      visit trays_items_path
      fill_in "Tray", :with => @tray2.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray2.id))
      fill_in "Item", :with => @item.barcode
      fill_in "Thickness", :with => Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(wrong_tray_path(:id => @tray2.id, :barcode => @item.barcode))
      expect(page).to have_content "Item #{@item.barcode} is already assigned to #{@tray.barcode}."
      expect(page).to have_content @item.barcode
      expect(page).to_not have_content @item.title
      expect(page).to_not have_content @item.chron
      expect(page).to_not have_content "Item #{@item.barcode} stocked in #{@tray.barcode}."
      click_button "OK"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
   end


    it "displays a tray's barcode while processing an item" do
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      fill_in "Thickness", :with => Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
    end

    it "displays items associated with a tray when processing items" do
      @items = []
      5.times do |i|
        @item = FactoryGirl.create(:item)
        @items << @item
      end
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      @items.each do |item|
        stub_request(:post, @template2).
          with(:body => {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"#{@tray.barcode}"},
            :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.9.1'}).
          to_return{ |response| { :status => 200, :body => {:results => {:status => "OK", :message => "Item stocked"}}.to_json, :headers => {} } }
        fill_in "Item", :with => item.barcode
        fill_in "Thickness", :with => Faker::Number.number(1)
        click_button "Save"
        expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      end
      @items.each do |item|
        expect(page).to have_content item.barcode
        expect(page).to have_content item.title
        expect(page).to have_content item.chron
      end
    end

    it "allows the user to remove an item from a tray" do
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      fill_in "Thickness", :with => Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @item.barcode
      click_button "Remove"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_no_content @item.barcode
    end

    it "allows the user to finish with the current tray when processing items" do
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      fill_in "Thickness", :with => Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @item.barcode
      click_button "Done"
      expect(current_path).to eq(trays_items_path)
    end

    it "allows the user to finish with the current tray when processing items via scan" do
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      fill_in "Thickness", :with => Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @item.barcode
      fill_in "Item", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(trays_items_path)
    end

    it "warns when a try is probably full" do
      @items = []
      14.times do
        @item = FactoryGirl.create(:item)
        @items << @item
      end
      @item2 = FactoryGirl.create(:item, tray: @tray, thickness: 6)
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      @items.each do |item|
        stub_request(:post, @template2).
          with(:body => {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"#{@tray.barcode}"},
            :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.9.1'}).
          to_return{ |response| { :status => 200, :body => {:results => {:status => "OK", :message => "Item stocked"}}.to_json, :headers => {} } }
        fill_in "Item", :with => item.barcode
        fill_in "Thickness", :with => 10
        click_button "Save"
      end
      expect(page).to have_content 'warning - tray may be full'
    end

    it "displays information about the tray the user just finished working with" do
      # pending "Not sure how to test this one yet, because when we're done it should leave that page and get ready for the next, I think."
    end

  end

  describe "when not signed in" do
    pending "add some scenarios (or delete) #{__FILE__}"
  end
end
