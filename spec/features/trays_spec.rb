require 'rails_helper'

feature "Trays", :type => :feature do
  describe "when signed in" do
    before(:each) do
      # signin_user @user
      # pending "add user sign in code"
    end

    it "can scan a new tray" do
      visit trays_path
      fill_in "Barcode", :with => 'TRAY-A1234'
      click_button "Save"
    end

  end

  describe "when not signed in" do
    pending "add some scenarios (or delete) #{__FILE__}"
  end
end
