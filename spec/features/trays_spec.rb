require 'rails_helper'

feature "Trays", :type => :feature do
  describe "when signed in" do
    before(:each) do
      # signin_user @user
      # pending "add user sign in code"
    end

    it "can scan a new tray" do
      @tray = FactoryGirl.create(:tray)
      visit trays_path
      fill_in "Barcode", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
    end

    it "associate a shelf with a tray" do
      @tray = FactoryGirl.create(:tray)
      @shelf = FactoryGirl.create(:shelf)
      visit trays_path
      fill_in "Barcode", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      fill_in "Barcode", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "Location: #{@shelf.barcode}"
    end

    it "can dissociate a shelf from a tray" do
      @tray = FactoryGirl.create(:tray)
      @shelf = FactoryGirl.create(:shelf)
      visit trays_path
      fill_in "Barcode", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      fill_in "Barcode", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "Location: #{@shelf.barcode}"
      click_button "DISSOCIATE"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
    end

    it "starts a new tray when finished with the current" do
      @tray = FactoryGirl.create(:tray)
      @shelf = FactoryGirl.create(:shelf)
      visit trays_path
      fill_in "Barcode", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      fill_in "Barcode", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "Location: #{@shelf.barcode}"
      click_button "Done"
      expect(current_path).to eq(trays_path)
    end

    it "can scan a new tray for processing items" do
      @tray = FactoryGirl.create(:tray)
      visit trays_items_path
      fill_in "Barcode", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
    end

    it "can scan an item for adding to a tray" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item)
      visit trays_items_path
      fill_in "Barcode", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Barcode", :with => @item.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
    end

    it "can select a width for an item" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item)
      visit trays_items_path
      fill_in "Barcode", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Barcode", :with => @item.barcode
      select(Faker::Number.number(1), :from => "Thickness")
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
    end

    it "requires a width for an item" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item)
      visit trays_items_path
      fill_in "Barcode", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Barcode", :with => @item.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content 'select a valid thickness'
    end

    it "displays an item after successfully adding it to a tray" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item)
      visit trays_items_path
      fill_in "Barcode", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Barcode", :with => @item.barcode
      select(Faker::Number.number(1), :from => "Thickness")
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @item.barcode
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
    end

    it "displays a tray's barcode while processing an item" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item)
      visit trays_items_path
      fill_in "Barcode", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Barcode", :with => @item.barcode
      select(Faker::Number.number(1), :from => "Thickness")
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
    end

    it "displays items associated with a tray when processing items" do
      @tray = FactoryGirl.create(:tray)
      @items = []
      5.times do |i|
        @items << FactoryGirl.create(:item)
      end
      visit trays_items_path
      fill_in "Barcode", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      @items.each do |item|
        fill_in "Barcode", :with => item.barcode
        select(Faker::Number.number(1), :from => "Thickness")
        click_button "Save"
        expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      end
      @items.each do |item|
        expect(page).to have_content item.barcode
        expect(page).to have_content item.title
        expect(page).to have_content item.author
        expect(page).to have_content item.chron
      end
    end

    it "allows the user to remove an item from a tray" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item)
      visit trays_items_path
      fill_in "Barcode", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Barcode", :with => @item.barcode
      select(Faker::Number.number(1), :from => "Thickness")
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @item.barcode
      click_button "Remove"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_no_content @item.barcode
    end

    it "allows the user to finish with the current tray when processing items" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item)
      visit trays_items_path
      fill_in "Barcode", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Barcode", :with => @item.barcode
      select(Faker::Number.number(1), :from => "Thickness")
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @item.barcode
      click_button "Done"
      expect(current_path).to eq(trays_items_path)
    end

    it "displays information about the tray the user just finished working with" do
    pending "add some scenarios (or delete) #{__FILE__}"
    pending "Not sure how to test this one yet, because when we're done it should leave that page and get ready for the next, I think."
    end

  end

  describe "when not signed in" do
    pending "add some scenarios (or delete) #{__FILE__}"
  end
end
