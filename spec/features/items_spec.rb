require 'rails_helper'

feature "Items", :type => :feature do
  include AuthenticationHelper

  describe "when signed in" do
    before(:each) do
      login_user

      template = Addressable::Template.new "#{Rails.application.secrets.api_server}/1.0/resources/items/record?auth_token=#{Rails.application.secrets.api_token}&barcode={barcode}"
      stub_request(:get, template). with(:headers => {'User-Agent'=>'Faraday v0.9.1'}). to_return{ |response| { :status => 200, :body => {"item_id" => "00110147500410", "barcode" => @item.barcode, "bib_id" => @item.bib_number, "sequence_number" => "00410", "admin_document_number" => "001101475", "call_number" => @item.call_number, "description" => @item.chron ,"title"=> @item.title, "author" => @item.author ,"publication" => "Cambridge, UK : Elsevier Science Publishers, c1991-", "edition" => "", "isbn_issn" =>@item.isbn_issn, "condition" => @item.conditions}.to_json, :headers => {} } }
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
      fill_in "Item", :with => @item2.barcode
      click_button "Find"
      expect(current_path).to eq(show_item_path(:id => @item2.id))
      fill_in "Item", :with => @item.barcode
      click_button "Scan"
      expect(current_path).to eq(show_item_path(:id => @item.id))
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
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
      expect(page).to have_content "Item #{@item.barcode} stocked in #{@tray.barcode}."
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
