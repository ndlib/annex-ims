require 'rails_helper'

feature "Items", :type => :feature do
  include AuthenticationHelper

  describe "when signed in" do
    before(:each) do
      login_user

      @tray = FactoryGirl.create(:tray)
      @shelf = FactoryGirl.create(:shelf)
      @tray2 = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item, tray: @tray, thickness: 1, title: 'ITEM 1', chron: 'TEST CHRON')
      @item2 = FactoryGirl.create(:item, tray: @tray2, thickness: 2, title: 'ITEM 2', chron: 'TEST CHRON2')

      uri2 = Addressable::URI.parse "http://1.0/resources/items/stock?auth_token=987654321"

      stub_request(:post, uri2).
        with(:body => {"barcode"=>"#{@item.barcode}", "item_id"=>"#{@item.id}", "tray_code"=>"#{@item.tray.barcode}"},
          :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.9.1'}).
        to_return{ |response| { :status => 200, :body => {:results => {:status => "OK", :message => "Item stocked"}}.to_json, :headers => {} } }

      uri = Addressable::URI.parse "http://1.0/resources/items/record?auth_token=987654321&barcode=#{@item.barcode}"
      stub_request(:get, uri). with(:headers => {'User-Agent'=>'Faraday v0.9.1'}). to_return{ |response| { :status => 200, :body => {"item_id" => "00110147500410", "barcode" => @item.barcode, "bib_id" => @item.bib_number, "sequence_number" => "00410", "admin_document_number" => "001101475", "call_number" => @item.call_number, "description" => @item.chron ,"title"=> @item.title, "author" => @item.author ,"publication" => "Cambridge, UK : Elsevier Science Publishers, c1991-", "edition" => "", "isbn_issn" =>@item.isbn_issn, "condition" => @item.conditions}.to_json, :headers => {} } }
    end

    after(:each) do
      ActivityLog.all.each do |log|
        log.destroy!
      end
    end

    it "can scan a new item" do
      visit items_path
      fill_in "Item", :with => @item.barcode
      click_button "Find"
      expect(current_path).to eq(show_item_path(:id => @item.id))
      expect(page).to have_content @item.title
      expect(page).to have_content @item.chron
    end

    it "can scan an item and then scan another item to change tasks" do
      visit items_path
      fill_in "Item", :with => @item.barcode
      click_button "Find"
      expect(current_path).to eq(show_item_path(:id => @item.id))
      fill_in "Item", :with => @item.barcode
      click_button "Scan"
      expect(current_path).to eq(show_item_path(:id => @item.id))
      expect(page).to have_content @item.title
      expect(page).to have_content @item.chron
    end

    it "can scan an item and then scan a tray to stock it" do
      visit items_path
      fill_in "Item", :with => @item.barcode
      click_button "Find"
      expect(current_path).to eq(show_item_path(:id => @item.id))
      fill_in "Tray", :with => @tray.barcode
      click_button "Scan"
      expect(current_path).to eq(items_path)
      expect(page).to have_content "Item #{@item.barcode} stocked in #{@tray.barcode}."
    end

    it "can scan an item and then scan a tray and show an error for the wrong tray" do
      visit items_path
      fill_in "Item", :with => @item.barcode
      click_button "Find"
      expect(current_path).to eq(show_item_path(:id => @item.id))
      fill_in "Tray", :with => @tray2.barcode
      click_button "Scan"
      expect(current_path).to eq(wrong_restock_path(:id => @item.id))
      expect(page).to have_content "Item #{@item.barcode} is already assigned to #{@tray.barcode}."
      click_button "OK"
      expect(current_path).to eq(show_item_path(:id => @item.id))
    end

    it "can view a list of issues associated with retrieving item data" do
      @issues = []
      10.times do
        @issue = FactoryGirl.create(:issue)
        @issues << @issue
      end
      visit issues_path
      @issues.each do |issue|
        expect(page).to have_content issue.user.username
        expect(page).to have_content issue.barcode
        expect(page).to have_content issue.message
        expect(page).to have_content issue.created_at
      end
    end

    it "can view a list of issues associated with retrieving item data and delete them" do
      @issues = []
      10.times do
        @issue = FactoryGirl.create(:issue)
        @issues << @issue
      end
      visit issues_path
      @issues.each do |issue|
        expect(page).to have_content issue.user.username
        expect(page).to have_content issue.barcode
        expect(page).to have_content issue.message
        expect(page).to have_content issue.created_at
        click_button "issue-#{issue.id}"
        expect(current_path).to eq(issues_path)
        expect(page).to_not have_content issue.barcode
      end
    end

  end
end
