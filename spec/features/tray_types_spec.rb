require "rails_helper"

feature "Tray Types", type: :feature do
  include AuthenticationHelper

  describe "as an admin" do
    before(:each) do
      login_admin
      visit root_path
    end

    it "can see Tray Types in the menu" do
      click_link "Settings"
      expect(page).to have_content "Manage tray types"
    end

    it "can access the Tray Types page" do
      click_link "Items"
      click_link "Manage tray types"
      expect(current_path).to eq(tray_types_path)
    end
  end

  describe "as a worker" do
    before(:each) do
      login_worker
      visit root_path
    end

    it "cannot see Tray Types in the menu" do
      expect(page).to_not have_content "Settings"
    end
  end
end
