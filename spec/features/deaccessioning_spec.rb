require "rails_helper"

feature "Deaccessioning", type: :feature do
  include AuthenticationHelper

  describe "as an admin" do
    before(:each) do
      login_admin
      visit root_path
    end

    it "can see Deaccessioning in the menu" do
      click_link "Items"
      expect(page).to have_content "Remove from Annex"
    end

    it "can access the Deaccessioning page" do
      click_link "Items"
      click_link "Remove from Annex"
      expect(current_path).to eq(deaccessioning_path)
    end
  end

  describe "as a worker" do
    before(:each) do
      login_worker
      visit root_path
    end

    it "cannot see Deaccessioning in the menu" do
      click_link "Items"
      expect(page).to_not have_content "Deaccessioning"
    end
  end
end
