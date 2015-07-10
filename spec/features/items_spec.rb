require 'rails_helper'

feature "Items", :type => :feature do
  include AuthenticationHelper

  describe "when signed in" do
    before(:each) do
      login_user

      @tray = FactoryGirl.create(:tray)
      @shelf = FactoryGirl.create(:shelf)
      @tray2 = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item, tray: @tray, thickness: 1, title: "The ubiquity of chaos / edited by Saul Krasner.", chron: "Chron")
      @item2 = FactoryGirl.create(:item, tray: @tray2, thickness: 2, title: "The ubiquity of chaos / edited by Saul Krasner.", chron: "Chron")
      @user = FactoryGirl.create(:user)
      @request = FactoryGirl.create(:request)

      stub_request(:post, api_stock_url).
        with(body: { barcode: "#{@item.barcode}", item_id: "#{@item.id}", tray_code: "#{@item.tray.barcode}" },
          headers: { "Content-Type" => "application/x-www-form-urlencoded", "User-Agent" => "Faraday v0.9.1" }).
        to_return({ status: 200, body: { results: { status: "OK", message: "Item stocked" } }.to_json, headers: {} })

      response_body = api_fixture_data("item_metadata.json")

      item_uri = api_item_url(@item)
      stub_request(:get, item_uri).
        with(headers: { "User-Agent" => "Faraday v0.9.1" }).
        to_return{ { status: 200, body: response_body, headers: {} } }
    end

    after(:each) do
      ActivityLog.all.each do |log|
        log.destroy!
      end
    end

    context "stocking items" do
      it "can scan a new item" do
        visit items_path
        fill_in "Item", with: @item.barcode
        click_button "Find"
        expect(current_path).to eq(show_item_path(id: @item.id))
        expect(page).to have_content @item.title
        expect(page).to have_content @item.chron
      end

      it "can scan an item and then scan another item to change tasks" do
        visit items_path
        fill_in "Item", with: @item.barcode
        click_button "Find"
        expect(current_path).to eq(show_item_path(id: @item.id))
        fill_in "Item", with: @item.barcode
        click_button "Scan"
        expect(current_path).to eq(show_item_path(id: @item.id))
        expect(page).to have_content @item.title
        expect(page).to have_content @item.chron
      end

      it "can scan an item and then scan a tray to stock it" do
        visit items_path
        fill_in "Item", with: @item.barcode
        click_button "Find"
        expect(current_path).to eq(show_item_path(id: @item.id))
        fill_in "Tray", with: @tray.barcode
        click_button "Scan"
        expect(current_path).to eq(items_path)
        expect(page).to have_content "Item #{@item.barcode} stocked in #{@tray.barcode}."
      end

      it "can scan an item and then scan a tray and show an error for the wrong tray" do
        visit items_path
        fill_in "Item", with: @item.barcode
        click_button "Find"
        expect(current_path).to eq(show_item_path(id: @item.id))
        fill_in "Tray", with: @tray2.barcode
        click_button "Scan"
        expect(current_path).to eq(wrong_restock_path(id: @item.id))
        expect(page).to have_content "Item #{@item.barcode} is already assigned to #{@tray.barcode}."
        click_button "OK"
        expect(current_path).to eq(show_item_path(id: @item.id))
      end
    end

    context "item issues" do
      it "can view a list of issues associated with retrieving item data" do
        @issues = []
        5.times do
          @issue = FactoryGirl.create(:issue)
          @issues << @issue
        end
        visit issues_path
        @issues.each do |issue|
          expect(page).to have_content issue.user.username
          expect(page).to have_content issue.barcode
          expect(page).to have_content I18n.t("issues.issue_type.#{issue.issue_type}")
          expect(page).to have_content issue.created_at
        end
      end

      it "can view a list of issues associated with retrieving item data and delete them" do
        @issues = []
        5.times do
          @issue = FactoryGirl.create(:issue)
          @issues << @issue
        end
        visit issues_path
        @issues.each do |issue|
          expect(page).to have_content issue.user.username
          expect(page).to have_content issue.barcode
          expect(page).to have_content I18n.t("issues.issue_type.#{issue.issue_type}")
          expect(page).to have_content issue.created_at
          click_button "issue-#{issue.id}"
          expect(current_path).to eq(issues_path)
          expect(page).to_not have_content issue.barcode
        end
      end
    end

    context "item details" do
      before(:each) do
        ActivityLogger.stock_item(item: @item, tray: @tray, user: @user)
        ActivityLogger.scan_item(item: @item, request: @request, user: @user)
        ActivityLogger.unstock_item(item: @item, tray: @tray, user: @user)
        ActivityLogger.stock_item(item: @item2, tray: @tray2, user: @user)
        ActivityLogger.ship_item(item: @item2, request: @request, user: @user)
        ActivityLogger.unstock_item(item: @item2, tray: @tray, user: @user)
      end

      it "displays item details" do
        visit item_detail_path(@item.barcode)
        expect(page).to have_content @item.status.humanize
        expect(page).to have_content @item.title
        expect(page).to have_content @item.author
        expect(page).to have_content @item.chron
      end

      it "displays item history" do
        visit item_detail_path(@item2.barcode)
        expect(page).to have_content "Stocked"
        expect(page).to have_content "Unstocked"
      end

      it "displays item usage" do
        visit item_detail_path(@item.barcode)
        expect(page).to have_content "Scanned"
        visit item_detail_path(@item2.barcode)
        expect(page).to have_content "Shipped"
      end
    end
  end
end
