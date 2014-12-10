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


  end

  describe "when not signed in" do
    pending "add some scenarios (or delete) #{__FILE__}"
  end
end
