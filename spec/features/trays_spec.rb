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
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
    end

# New workflow from spreadsheet. Take priority over previous code.

    it "runs through unassigned-unshelved-cancel flow" do
      @tray = FactoryGirl.create(:tray)
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
      expect(current_path).to eq(wrong_tray_path(:id => @tray.id))
      expect(page).to have_content "#{@tray.barcode} belongs to #{@shelf.barcode}, but #{@shelf2.barcode} was scanned."
      click_button "Shelve"
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
      expect(current_path).to eq(wrong_tray_path(:id => @tray.id))
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
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content "Unshelved"
    end

# End new workflow.

#I'm not entirely sure what to do with these tests. Isn't all this behaviour encapsulated in the new work flow?
=begin
    it "can associate a shelf with a tray" do
      @tray = FactoryGirl.create(:tray)
      @shelf = FactoryGirl.create(:shelf)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "Location: #{@shelf.barcode}"
      expect(page).to have_content "Shelved"
    end

    it "can dissociate a shelf from a tray" do
      @tray = FactoryGirl.create(:tray)
      @shelf = FactoryGirl.create(:shelf)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      fill_in "Shelf", :with => @shelf.barcode
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
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "Location: #{@shelf.barcode}"
      click_button "Done"
      expect(current_path).to eq(trays_path)
    end

    it "starts a new tray when finished with the current via scan" do
      @tray = FactoryGirl.create(:tray)
      @shelf = FactoryGirl.create(:shelf)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "Location: #{@shelf.barcode}"
      fill_in "Shelf", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(trays_path)
    end

    it "lets you mark a tray as being unshelved" do
      @tray = FactoryGirl.create(:tray)
      @shelf = FactoryGirl.create(:shelf)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "Location: #{@shelf.barcode}"
      expect(page).to have_content "Shelved"
      click_button "Unshelve"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "Location: #{@shelf.barcode}"
      expect(page).to have_content "Unshelved"
    end

    it "lets you mark a tray as unshelved without losing its association to a shelf" do
      @tray = FactoryGirl.create(:tray)
      @shelf = FactoryGirl.create(:shelf)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "Location: #{@shelf.barcode}"
      expect(page).to have_content "Shelved"
      click_button "Unshelve"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "Location: #{@shelf.barcode}"
      expect(page).to have_content "Unshelved"
    end

    it "unshelves a tray when you dissociate it from a shelf" do
      @tray = FactoryGirl.create(:tray)
      @shelf = FactoryGirl.create(:shelf)
      visit trays_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      fill_in "Shelf", :with => @shelf.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "Location: #{@shelf.barcode}"
      click_button "DISSOCIATE"
      expect(current_path).to eq(show_tray_path(:id => @tray.id))
      expect(page).to have_content @tray.barcode
      expect(page).to have_content "STAGING"
      expect(page).to have_content "Unshelved"
    end
=end

    it "can scan a new tray for processing items" do
      @tray = FactoryGirl.create(:tray)
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
    end

    it "can scan an item for adding to a tray" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item)
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
      @item = FactoryGirl.create(:item)
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      select(Faker::Number.number(1), :from => "Thickness")
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
    end

    it "requires a width for an item" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item)
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
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item)
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      select(Faker::Number.number(1), :from => "Thickness")
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @item.barcode
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
    end

   it "displays information about a successful association made" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item)
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      select(Faker::Number.number(1), :from => "Thickness")
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @item.barcode
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
      expect(page).to have_content "Item #{@item.barcode} associated with Tray #{@tray.barcode}."
   end

    it "displays a tray's barcode while processing an item" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item)
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
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
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      @items.each do |item|
        fill_in "Item", :with => item.barcode
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
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
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
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      select(Faker::Number.number(1), :from => "Thickness")
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @item.barcode
      click_button "Done"
      expect(current_path).to eq(trays_items_path)
    end

    it "allows the user to finish with the current tray when processing items via scan" do
      @tray = FactoryGirl.create(:tray)
      @item = FactoryGirl.create(:item)
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      fill_in "Item", :with => @item.barcode
      select(Faker::Number.number(1), :from => "Thickness")
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      expect(page).to have_content @item.barcode
      fill_in "Item", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(trays_items_path)
    end

    it "warns when a try is probably full" do
      @tray = FactoryGirl.create(:tray)
      @items = []
      5.times do
        @items << FactoryGirl.create(:item)
      end
      visit trays_items_path
      fill_in "Tray", :with => @tray.barcode
      click_button "Save"
      expect(current_path).to eq(show_tray_item_path(:id => @tray.id))
      @items.each do |item|
        fill_in "Item", :with => item.barcode
        select(10, :from => "Thickness")
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
