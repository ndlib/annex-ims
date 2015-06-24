require 'rails_helper'

feature "Shelves", :type => :feature do
  include AuthenticationHelper

  describe "when signed in" do
    before(:each) do
      @shelf = FactoryGirl.create(:shelf)
      @tray = FactoryGirl.create(:tray, shelf: @shelf, barcode: "TRAY-#{@shelf.barcode}")
      @shelf2 = FactoryGirl.create(:shelf)
      @tray2 = FactoryGirl.create(:tray, shelf: @shelf2, barcode: "TRAY-#{@shelf2.barcode}")
      @item = FactoryGirl.create(:item, barcode: "123456", thickness:1, title: 'ITEM 1', tray: @tray)
      @item2 = FactoryGirl.create(:item, title: 'ITEM 2')
      @tray2 = FactoryGirl.create(:tray, barcode: "TRAY-AH11", shelf: @shelf2)
      @item3 = FactoryGirl.create(:item, barcode: "1234567", tray: @tray2)

      login_user

      item_uri = api_url("1.0/resources/items/record", barcode: @item.barcode)

      @stock_uri = api_url("1.0/resources/items/stock")

      stub_request(:get, item_uri). with(:headers => {'User-Agent'=>'Faraday v0.9.1'}). to_return{ |response| { :status => 200, :body => {"item_id" => "00110147500410", "barcode" => @item.barcode, "bib_id" => @item.bib_number, "sequence_number" => "00410", "admin_document_number" => "001101475", "call_number" => @item.call_number, "description" => @item.chron ,"title"=> @item.title, "author" => @item.author ,"publication" => "Cambridge, UK : Elsevier Science Publishers, c1991-", "edition" => "", "isbn_issn" =>@item.isbn_issn, "condition" => @item.conditions}.to_json, :headers => {} } }

      stub_request(:post, @stock_uri).
        with(:body => {"barcode"=>"#{@item.barcode}", "item_id"=>"#{@item.id}", "tray_code"=>"#{@item.tray.barcode}"},
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
      Shelf.all.each do |shelf|
        shelf.destroy!
      end
    end

    it "can scan a new shelf for processing items" do
      visit shelves_path
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
    end

    it "can scan an item for adding to a shelf" do
      visit shelves_path
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      fill_in "Item", :with => @item.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
    end

    it "displays an item after successfully adding it to a shelf" do
      visit shelves_path
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      fill_in "Item", :with => @item.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      expect(page).to have_content @item.barcode
      expect(page).to have_content @item.title
      expect(page).to have_content @item.chron
    end

   it "displays information about a successful association made" do
      visit shelves_path
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      @item.tray = nil
      @item.save!
      fill_in "Item", :with => @item.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      expect(page).to have_content @item.barcode
      expect(page).to have_content @item.title
      expect(page).to have_content @item.chron
      expect(page).to have_content "Item #{@item.barcode} stocked in #{@shelf.barcode}."
   end

   it "accepts re-associating an item to the same shelf" do
      visit shelves_path
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      @item.tray = nil
      @item.save!
      fill_in "Item", :with => @item.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      expect(page).to have_content @item.barcode
      expect(page).to have_content @item.title
      expect(page).to have_content @item.chron
      expect(page).to have_content "Item #{@item.barcode} stocked in #{@shelf.barcode}."
      fill_in "Item", :with => @item.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      expect(page).to have_content @item.barcode
      expect(page).to have_content @item.title
      expect(page).to have_content @item.chron
      expect(page).to have_content "Item #{@item.barcode} already assigned to #{@shelf.barcode}. Record updated."
   end


   it "rejects associating an item to the wrong shelf" do
      visit shelves_path
      fill_in "Shelf", :with => @shelf2.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf2.id))
      fill_in "Item", :with => @item.barcode
      click_button "Save"
      expect(current_path).to eq(wrong_shelf_item_path(:id => @shelf2.id, :barcode => @item.barcode))
      expect(page).to have_content "Item #{@item.barcode} is already assigned to #{@shelf.barcode}."
      expect(page).to have_content @item.barcode
      expect(page).to_not have_content @item.title
      expect(page).to_not have_content @item.chron
      expect(page).to_not have_content "Item #{@item.barcode} stocked in #{@shelf2.barcode}."
      click_button "OK"
      expect(current_path).to eq(show_shelf_path(:id => @shelf2.id))
   end


    it "displays a shelf's barcode while processing an item" do
      visit shelves_path
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      fill_in "Item", :with => @item.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      expect(page).to have_content @shelf.barcode
    end

    it "displays items associated with a shelf when processing items" do
      @items = []
      visit shelves_path
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      5.times do |i|
        item = FactoryGirl.create(:item, title: "Item #{i + 1}")
        @items << item
        item_uri = api_url("1.0/resources/items/record", barcode: item.barcode)
        stub_request(:get, item_uri). with(:headers => {'User-Agent'=>'Faraday v0.9.1'}). to_return{ |response| { :status => 200, :body => {"item_id" => "00110147500410", "barcode" => item.barcode, "bib_id" => item.bib_number, "sequence_number" => "00410", "admin_document_number" => "001101475", "call_number" => item.call_number, "description" => item.chron ,"title"=> item.title, "author" => item.author ,"publication" => "Cambridge, UK : Elsevier Science Publishers, c1991-", "edition" => "", "isbn_issn" =>item.isbn_issn, "condition" => item.conditions}.to_json, :headers => {} } }
        stub_request(:post, @stock_uri).
          with(:body => {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"TRAY-#{@shelf.barcode}"},
            :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.9.1'}).
          to_return{ |response| { :status => 200, :body => {:results => {:status => "OK", :message => "Item stocked"}}.to_json, :headers => {} } }
        fill_in "Item", :with => item.barcode
        click_button "Save"
        expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      end
      @items.each do |item|
        expect(page).to have_content item.barcode
        expect(page).to have_content item.title
        expect(page).to have_content item.chron
      end
    end

    it "allows the user to remove an item from a shelf" do
      visit shelves_path
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      fill_in "Item", :with => @item.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      expect(page).to have_content @item.barcode
      click_button "Remove"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      expect(page).to have_no_content @item.barcode
    end

    it "allows the user to finish with the current shelf when processing items" do
      visit shelves_path
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      fill_in "Item", :with => @item.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      expect(page).to have_content @item.barcode
      click_button "Done"
      expect(current_path).to eq(shelves_path)
    end

    it "allows the user to finish with the current shelf when processing items via scan" do
      visit shelves_path
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      fill_in "Item", :with => @item.barcode
      click_button "Save"
      expect(current_path).to eq(show_shelf_path(:id => @shelf.id))
      expect(page).to have_content @item.barcode
      fill_in "Item", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(shelves_path)
    end

    it "displays information about the shelf the user just finished working with" do
      # pending "Not sure how to test this one yet, because when we're done it should leave that page and get ready for the next, I think."
    end

  end

  describe "when not signed in" do
    pending "add some scenarios (or delete) #{__FILE__}"
  end
end
