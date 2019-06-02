require 'rails_helper'

feature "Trays", type: :feature do
  include AuthenticationHelper

  before(:all) do
    FactoryGirl.create(:tray_type)
    FactoryGirl.create(:tray_type, code: "AH")
  end

  let(:tray_barcode) { "TRAY-AL1234" }
  let(:tray) { FactoryGirl.create(:tray, barcode: tray_barcode) }
  let(:item) { FactoryGirl.create(:item, barcode: rand.to_s[2..15]) }
  let(:shelf) { FactoryGirl.create(:shelf) }
  let(:response_body) { api_fixture_data("item_metadata.json") }

  describe "when signed in" do
    before(:each) do
      login_admin

      stub_request(:get, api_item_url(item)).
        with(headers: { "User-Agent" => "Faraday v0.15.3" }).
        to_return{ { status: 200, body: response_body, headers: {} } }

      stub_request(:post, api_stock_url).
        with(body: {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"#{tray.barcode}"},
          headers: {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.15.3'}).
        to_return{ |response| { status: 200, body: {results: {status: "OK", message: "Item stocked"}}.to_json, headers: {} } }

    end

    it "can scan a new tray" do
      tray
      visit trays_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(id: tray.id))
      expect(page).to have_content tray.barcode
      expect(page).to have_content "STAGING"
    end

    it "runs through unassigned-unshelved-cancel flow" do
      tray
      visit trays_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(id: tray.id))
      expect(page).to have_content tray.barcode
      expect(page).to have_content "STAGING"
      expect{page.find_by_id("pull")}.to raise_error
      expect{page.find_by_id("unassign")}.to raise_error
      click_button "Cancel"
      expect(current_path).to eq(trays_path)
    end

    context "unassigned tray" do
      let(:tray) { FactoryGirl.create(:tray, shelf: nil, shelved: false, barcode: tray_barcode) }

      it "runs through unassigned-unshelved-scan flow" do
        visit trays_path
        fill_in "Tray", with: tray.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray.id))
        expect(page).to have_content tray.barcode
        expect(page).to have_content "STAGING"
        expect{page.find_by_id("pull")}.to raise_error
        expect{page.find_by_id("unassign")}.to raise_error
        fill_in "Shelf", with: shelf.barcode
        click_button "Save"
        expect(current_path).to eq(trays_path)
      end

      it "runs through unassigned-unshelved-scan flow and check shelf size, allow same size" do
        tray2 = FactoryGirl.create(:tray, shelf: nil, shelved: false)
        visit trays_path
        fill_in "Tray", with: tray.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray.id))
        expect(page).to have_content tray.barcode
        expect(page).to have_content "STAGING"
        expect{page.find_by_id("pull")}.to raise_error
        expect{page.find_by_id("unassign")}.to raise_error
        fill_in "Shelf", with: shelf.barcode
        click_button "Save"
        expect(current_path).to eq(trays_path)
        fill_in "Tray", with: tray2.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray2.id))
        expect(page).to have_content tray2.barcode
        expect(page).to have_content "STAGING"
        expect{page.find_by_id("pull")}.to raise_error
        expect{page.find_by_id("unassign")}.to raise_error
        fill_in "Shelf", with: shelf.barcode
        click_button "Save"
        expect(current_path).to eq(trays_path)
      end

      it "runs through unassigned-unshelved-scan flow and check shelf size, reject different size" do
        tray2 = FactoryGirl.create(:tray, shelf: nil, shelved: false, barcode: "TRAY-AH1234")
        visit trays_path
        fill_in "Tray", with: tray.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray.id))
        expect(page).to have_content tray.barcode
        expect(page).to have_content "STAGING"
        expect{page.find_by_id("pull")}.to raise_error
        expect{page.find_by_id("unassign")}.to raise_error
        fill_in "Shelf", with: shelf.barcode
        click_button "Save"
        expect(current_path).to eq(trays_path)
        fill_in "Tray", with: tray2.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray2.id))
        expect(page).to have_content tray2.barcode
        expect(page).to have_content "STAGING"
        expect{page.find_by_id("pull")}.to raise_error
        expect{page.find_by_id("unassign")}.to raise_error
        fill_in "Shelf", with: shelf.barcode
        click_button "Save"
        expect(page).to have_content "tray sizes must match"
        expect(current_path).to eq(show_tray_path(id: tray2.id))
      end

      it "runs through unassigned-unshelved-scan flow and check shelf size, accept different size after removing one" do
        tray2 = FactoryGirl.create(:tray, shelf: nil, shelved: false, barcode: "TRAY-AH1236")
        visit trays_path
        fill_in "Tray", with: tray.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray.id))
        expect(page).to have_content tray.barcode
        expect(page).to have_content "STAGING"
        expect{page.find_by_id("pull")}.to raise_error
        expect{page.find_by_id("unassign")}.to raise_error
        fill_in "Shelf", with: shelf.barcode
        click_button "Save"
        expect(current_path).to eq(trays_path)
        fill_in "Tray", with: tray.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray.id))
        expect(page).to have_content tray.barcode
        click_button "Unassign"
        expect(current_path).to eq(trays_path)
        fill_in "Tray", with: tray2.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray2.id))
        expect(page).to have_content tray2.barcode
        expect(page).to have_content "STAGING"
        expect{page.find_by_id("pull")}.to raise_error
        expect{page.find_by_id("unassign")}.to raise_error
        fill_in "Shelf", with: shelf.barcode
        click_button "Save"
        expect(current_path).to eq(trays_path)
      end

      it "warns when a shelf is full" do
        @shelf = FactoryGirl.create(:shelf)
        tray.tray_type.trays_per_shelf.times do
          FactoryGirl.create(:tray, shelf: @shelf)
        end
        visit trays_path
        fill_in "Tray", with: tray.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray.id))
        expect(page).to have_content tray.barcode
        expect(page).to have_content "STAGING"
        expect{page.find_by_id("pull")}.to raise_error
        expect{page.find_by_id("unassign")}.to raise_error
        fill_in "Shelf", with: @shelf.barcode
        click_button "Save"
        expect(current_path).to eq(trays_path)

        expect(page).to have_content 'warning - shelf may be full'
      end
    end

    context "assigned-unshelved tray" do
      let(:tray) { FactoryGirl.create(:tray, shelf: shelf, shelved: false, barcode: tray_barcode) }

      it "runs through assigned-unshelved-cancel flow" do
        visit trays_path
        fill_in "Tray", with: tray.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray.id))
        expect(page).to have_content tray.barcode
        expect{page.find_by_id("pull")}.to raise_error
        click_button "Cancel"
        expect(current_path).to eq(trays_path)
      end

      it "runs through assigned-unshelved-unassign flow" do
        visit trays_path
        fill_in "Tray", with: tray.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray.id))
        expect(page).to have_content tray.barcode
        expect{page.find_by_id("pull")}.to raise_error
        click_button "Unassign"
        expect(current_path).to eq(trays_path)
      end

      it "runs through assigned-unshelved-scan-same flow" do
        visit trays_path
        fill_in "Tray", with: tray.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray.id))
        expect(page).to have_content tray.barcode
        expect{page.find_by_id("pull")}.to raise_error
        fill_in "Shelf", with: shelf.barcode
        click_button "Shelve"
        expect(current_path).to eq(trays_path)
      end

      it "runs through assigned-unshelved-scan-different-shelve flow" do
        shelf2 = FactoryGirl.create(:shelf, barcode: "SHELF-11111")
        visit trays_path
        fill_in "Tray", with: tray.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray.id))
        expect(page).to have_content tray.barcode
        expect{page.find_by_id("pull")}.to raise_error
        fill_in "Shelf", with: shelf2.barcode
        click_button "Shelve"
        expect(current_path).to eq(wrong_shelf_path(id: tray.id))
        expect(page).to have_content "#{tray.barcode} belongs to #{shelf.barcode}, but #{shelf2.barcode} was scanned."
        click_button "Shelve Anyway"
        expect(current_path).to eq(trays_path)
      end

      it "runs through assigned-unshelved-scan-different flow-cancel" do
        shelf2 = FactoryGirl.create(:shelf, barcode: "SHELF-11112")
        visit trays_path
        fill_in "Tray", with: tray.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray.id))
        expect(page).to have_content tray.barcode
        expect{page.find_by_id("pull")}.to raise_error
        fill_in "Shelf", with: shelf2.barcode
        click_button "Shelve"
        expect(current_path).to eq(wrong_shelf_path(id: tray.id))
        expect(page).to have_content "#{tray.barcode} belongs to #{shelf.barcode}, but #{shelf2.barcode} was scanned."
        click_button "Cancel"
        expect(current_path).to eq(trays_path)
      end
    end

    context "assigned-shelved tray" do
      let(:tray) { FactoryGirl.create(:tray, shelf: shelf, shelved: true, barcode: tray_barcode) }

      it "runs through assigned-shelved-cancel flow" do
        visit trays_path
        fill_in "Tray", with: tray.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray.id))
        expect(page).to have_content tray.barcode
        expect{page.find_by_id("barcode")}.to raise_error
        click_button "Cancel"
        expect(current_path).to eq(trays_path)
      end

      it "runs through assigned-shelved-unassign flow" do
        visit trays_path
        fill_in "Tray", with: tray.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray.id))
        expect(page).to have_content tray.barcode
        expect{page.find_by_id("barcode")}.to raise_error
        click_button "Unassign"
        expect(current_path).to eq(trays_path)
      end

      it "runs through assigned-shelved-pull flow" do
        visit trays_path
        fill_in "Tray", with: tray.barcode
        click_button "Save"
        expect(current_path).to eq(show_tray_path(id: tray.id))
        expect(page).to have_content tray.barcode
        expect{page.find_by_id("barcode")}.to raise_error
        click_button "Pull"
        expect(current_path).to eq(trays_path)
      end
    end

    it "can scan a new tray for processing items" do
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
    end

    it "can scan an item for adding to a tray" do
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
    end

    it "can select a width for an item" do
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
    end

    it "requires a thickness for an item" do
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      expect(page).to have_content "select a valid thickness"
    end

    it "requires a valid thickness for an item" do
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Thickness", with: "error"
      fill_in "Item", with: item.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      expect(page).to have_content "select a valid thickness"
    end

    it "displays an item after successfully adding it to a tray" do
      expect(GetItemFromBarcode).to receive(:call).with(barcode: item.barcode, user_id: @user.id).and_return(item).at_least :once
      stub_request(:post, api_stock_url).
      with(body: {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"#{tray.barcode}"},
        headers: {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.15.3'}).
      to_return{ |response| { status: 200, body: {results: {status: "OK", message: "Item stocked"}}.to_json, headers: {} } }
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      expect(page).to have_content item.barcode
      expect(page).to have_content item.title
      expect(page).to have_content item.thickness
      expect(page).to have_content item.chron
    end

    it "displays information about a successful association made" do
      expect(GetItemFromBarcode).to receive(:call).with(barcode: item.barcode, user_id: @user.id).and_return(item).at_least :once
      stub_request(:post, api_stock_url).
      with(body: {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"#{tray.barcode}"},
        headers: {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.15.3'}).
      to_return{ |response| { status: 200, body: {results: {status: "OK", message: "Item stocked"}}.to_json, headers: {} } }
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      expect(page).to have_content item.barcode
      expect(page).to have_content item.title
      expect(page).to have_content item.thickness
      expect(page).to have_content item.chron
      expect(page).to have_content "Item #{item.barcode} stocked in #{tray.barcode}."
    end

    it "accepts re-associating an item to the same tray" do
      expect(GetItemFromBarcode).to receive(:call).with(barcode: item.barcode, user_id: @user.id).and_return(item).at_least :once
      item_uri = api_item_url(item)
      stub_request(:get, item_uri).
        with(headers: { "User-Agent"=>"Faraday v0.15.3" }).
        to_return{ { status: 200, body: response_body, headers: {} } }
      stub_request(:post, api_stock_url).
        with(body: {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"#{tray.barcode}"},
          headers: {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.15.3'}).
        to_return{ |response| { status: 200, body: {results: {status: "OK", message: "Item stocked"}}.to_json, headers: {} } }
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      expect(page).to have_content item.barcode
      expect(page).to have_content item.title
      expect(page).to have_content item.thickness
      expect(page).to have_content item.chron
      expect(page).to have_content "Item #{item.barcode} stocked in #{tray.barcode}."
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      expect(page).to have_content item.barcode
      expect(page).to have_content item.title
      expect(page).to have_content item.thickness
      expect(page).to have_content item.chron
      expect(page).to have_content "Item #{item.barcode} already assigned to #{tray.barcode}. Record updated."
    end

    it "rejects associating an item to the wrong tray" do
      tray2 = FactoryGirl.create(:tray)
      item.tray = tray2
      expect(GetItemFromBarcode).to receive(:call).with(barcode: item.barcode, user_id: @user.id).and_return(item).at_least :once
      stub_request(:post, api_stock_url).
        with(body: {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"#{tray2.barcode}"},
          headers: {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.15.3'}).
        to_return{ |response| { status: 200, body: {results: {status: "OK", message: "Item stocked"}}.to_json, headers: {} } }
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(wrong_tray_path(id: tray.id, barcode: item.barcode))
      expect(page).to have_content "Item #{item.barcode} is already assigned to #{tray2.barcode}."
      expect(page).to have_content item.barcode
      expect(page).to_not have_content item.title
      expect(page).to_not have_content item.chron
      expect(page).to_not have_content "Item #{item.barcode} stocked in #{tray.barcode}."
      click_button "OK"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
    end

    it "redirects to invalid tray item path if an item has a invalid barcode" do
      item = FactoryGirl.create(:item, barcode: rand(36**7).to_s(36))
      visit show_tray_item_path(id: tray.id)
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(invalid_tray_item_path(id: tray.id))
    end

    it "show tray item path after clicking 'Rescan' link on the invalid tray item page" do
      item = FactoryGirl.create(:item, barcode: rand(36**7).to_s(36))
      visit show_tray_item_path(id: tray.id)
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(invalid_tray_item_path(id: tray.id))
      click_link "Rescan"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
    end

    it "redirects to invalid tray item path two times via clicking 'Rescan' link on the invalid tray item page" do
      item = FactoryGirl.create(:item, barcode: rand(36**7).to_s(36))
      visit show_tray_item_path(id: tray.id)
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(invalid_tray_item_path(id: tray.id))
      click_link "Rescan"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(invalid_tray_item_path(id: tray.id))
    end

    it "redirects to create tray item path after clicking 'Set aside' link on the invalid tray item page" do
      item2 = FactoryGirl.create(:item, barcode: rand(36**7).to_s(36))
      visit show_tray_item_path(id: tray.id)
      fill_in "Item", with: item2.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(invalid_tray_item_path(id: tray.id))
      click_button "Set aside"
      expect(current_path).to have_content(create_tray_item_path(id: tray.id))
    end

    it "displays a tray's barcode while processing an item" do
      item_uri = api_item_url(item)
      stub_request(:get, item_uri).
        with(headers: { "User-Agent" => "Faraday v0.15.3" }).
        to_return{ { status: 200, body: response_body, headers: {} } }
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      expect(page).to have_content tray.barcode
    end

    it "displays items associated with a tray when processing items" do
      items = []
      5.times do |i|
        item = FactoryGirl.create(:item, barcode: rand.to_s[2..15])
        items << item
      end
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      items.each do |item|
        expect(GetItemFromBarcode).to receive(:call).with(barcode: item.barcode, user_id: @user.id).and_return(item).at_least :once
        item_uri = api_item_url(item)
        stub_request(:post, item_uri).
          with(body: {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"#{tray.barcode}"},
            headers: {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.15.3'}).
          to_return{ |response| { status: 200, body: {results: {status: "OK", message: "Item stocked"}}.to_json, headers: {} } }
        stub_request(:post, api_stock_url).
          with(body: {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"#{tray.barcode}"},
            headers: {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0..15.3'}).
          to_return{ |response| { status: 200, body: {results: {status: "OK", message: "Item stocked"}}.to_json, headers: {} } }
        fill_in "Item", with: item.barcode
        fill_in "Thickness", with: Faker::Number.number(1)
        click_button "Save"
        expect(current_path).to eq(show_tray_item_path(id: tray.id))
      end
      items.each do |item|
        expect(page).to have_content item.barcode
        expect(page).to have_content item.title
        expect(page).to have_content item.chron
      end
    end

    it "allows the user to remove an item from a tray" do
      item_uri = api_item_url(item)
      stub_request(:get, item_uri).
        with(headers: { "User-Agent" => "Faraday v0.15.3" }).
        to_return{ { status: 200, body: response_body, headers: {} } }
      stub_request(:post, api_stock_url).
        with(body: {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"#{tray.barcode}"},
          headers: {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.15.3'}).
        to_return{ |response| { status: 200, body: {results: {status: "OK", message: "Item stocked"}}.to_json, headers: {} } }
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      expect(page).to have_content item.barcode
      click_button "Unassign"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      expect(page).to have_no_content item.barcode
    end

    it "skips the tray counts when the user is an admin" do
      login_admin
      item_uri = api_item_url(item)
      stub_request(:get, item_uri).
        with(headers: { "User-Agent" => "Faraday v0.15.3" }).
        to_return { { status: 200, body: response_body, headers: {} } }
      stub_request(:post, api_stock_url).
        with(body: { "barcode" => "#{item.barcode}", "item_id" => "#{item.id}", "tray_code" => "#{tray.barcode}" },
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Faraday v0.15.3' }).
        to_return{ |response| { status: 200, body: { results: { status: "OK", message: "Item stocked" } }.to_json, headers: {} } }
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      expect(page).to have_content item.barcode
      click_button "Done"
      expect(current_path).to eq(trays_items_path)
    end

    it "allows the user to finish with the current tray when processing items" do
      login_worker
      item_uri = api_item_url(item)
      stub_request(:get, item_uri).
        with(headers: { "User-Agent" => "Faraday v0.15.3" }).
        to_return{ { status: 200, body: response_body, headers: {} } }
      stub_request(:post, api_stock_url).
        with(body: {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"#{tray.barcode}"},
          headers: {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.15.3'}).
        to_return{ |response| { status: 200, body: {results: {status: "OK", message: "Item stocked"}}.to_json, headers: {} } }
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      expect(page).to have_content item.barcode
      click_button "Done"
      expect(current_path).to eq(count_tray_item_path(id: tray.id))
    end

    it "allows a worker user to validate same Manual and System counts of items in the tray" do
      login_worker
      item_uri = api_item_url(item)
      stub_request(:get, item_uri).
        with(headers: { "User-Agent" => "Faraday v0.15.3" }).
        to_return { { status: 200, body: response_body, headers: {} } }
      stub_request(:post, api_stock_url).
        with(body: { "barcode" => "#{item.barcode}", "item_id" => "#{item.id}", "tray_code" => "#{tray.barcode}" },
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Faraday v0.15.3' }).
        to_return{ |response| { status: 200, body: { results: { status: "OK", message: "Item stocked" } }.to_json, headers: {} } }
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      expect(page).to have_content item.barcode
      click_button "Done"
      expect(current_path).to eq(count_tray_item_path(id: tray.id))
      fill_in "Items in Tray", with: 1
      click_button "Enter"
      expect(current_path).to eq(trays_items_path)
    end

    it "allows a worker user to validate different Manual and System counts of items in the tray" do
      login_worker
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      click_button "Done"
      expect(current_path).to eq(count_tray_item_path(id: tray.id))
      fill_in "Items in Tray", with: 1
      click_button "Enter"
      expect(current_path).to eq(count_tray_item_path(id: tray.id))
      expect(page).to have_content I18n.t("trays.count_items_not_match")
    end

    it "allows a worker user to validate two times Manual and System counts of items in the tray" do
      login_worker
      item_uri = api_item_url(item)
      stub_request(:get, item_uri).
        with(headers: { "User-Agent" => "Faraday v0.15.3" }).
        to_return { { status: 200, body: response_body, headers: {} } }
      stub_request(:post, api_stock_url).
        with(body: { "barcode" => "#{item.barcode}", "item_id" => "#{item.id}", "tray_code" => "#{tray.barcode}" },
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded', 'User-Agent' => 'Faraday v0.15.3' }).
        to_return { |response| { status: 200, body: { results: { status: "OK", message: "Item stocked" } }.to_json, headers: {} } }
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      expect(page).to have_content item.barcode
      click_button "Done"
      expect(current_path).to eq(count_tray_item_path(id: tray.id))
      fill_in "Items in Tray", with: 2
      click_button "Enter"
      expect(current_path).to eq(count_tray_item_path(id: tray.id))
      fill_in "Items in Tray", with: 4
      click_button "Enter"
      expect(current_path).to eq(count_tray_item_path(id: tray.id))
      expect(page).to have_content I18n.t("trays.count_validation_not_pass")
      click_button "OK"
      expect(current_path).to eq(trays_items_path)
    end

    it "allows the user to finish with the current tray when processing items via scan" do
      item_uri = api_item_url(item)
      stub_request(:get, item_uri).
        with(headers: { "User-Agent" => "Faraday v0.15.3" }).
        to_return{ { status: 200, body: response_body, headers: {} } }
      stub_request(:post, api_stock_url).
        with(body: {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"#{tray.barcode}"},
          headers: {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.15.3'}).
        to_return{ |response| { status: 200, body: {results: {status: "OK", message: "Item stocked"}}.to_json, headers: {} } }
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      fill_in "Item", with: item.barcode
      fill_in "Thickness", with: Faker::Number.number(1)
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      expect(page.find(".progress-bar")[:class].include?("progress-bar-success")).to eq true
      expect(page).to have_content "#{tray.used} / #{tray.capacity}"
      expect(page).to have_content item.barcode
      fill_in "Item", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(trays_items_path)
    end

    it "warns when a tray is probably full" do
      login_worker
      items = []
      14.times do
        item = FactoryGirl.create(:item, barcode: rand.to_s[2..15])
        items << item
      end
      visit trays_items_path
      fill_in "Tray", with: tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(id: tray.id))
      items.each do |item|
        expect(GetItemFromBarcode).to receive(:call).with(barcode: item.barcode, user_id: @user.id).and_return(item).at_least :once
        item_uri = api_item_url(item)
        stub_request(:post, item_uri).
          with(body: {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"#{tray.barcode}"},
            headers: {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.15.3'}).
          to_return{ |response| { status: 200, body: {results: {status: "OK", message: "Item stocked"}}.to_json, headers: {} } }
        stub_request(:post, api_stock_url).
          with(body: {"barcode"=>"#{item.barcode}", "item_id"=>"#{item.id}", "tray_code"=>"#{tray.barcode}"},
            headers: {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.15.3'}).
          to_return{ |response| { status: 200, body: {results: {status: "OK", message: "Item stocked"}}.to_json, headers: {} } }
        fill_in "Item", with: item.barcode
        fill_in "Thickness", with: 100
        click_button "Save"
      end
      expect(page).to have_content 'warning - tray may be full'
      expect(page.find(".progress-bar")[:class].include?("progress-bar-danger")).to eq true
      expect(page).to have_content "#{tray.used} / #{tray.capacity}"
    end
  end
end
