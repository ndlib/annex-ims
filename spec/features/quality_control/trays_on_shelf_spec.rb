require 'rails_helper'

feature "Trays on Shelf", type: :feature do
  include AuthenticationHelper

  describe "as an admin" do
    before(:each) do
      login_admin
      visit root_path
    end

    it "can see Trays on Shelf in the menu" do
      click_link "Quality Control"
      expect(page).to have_content "Trays on Shelf"
    end

    it "can access the Trays on Shelf page" do
      click_link "Quality Control"
      click_link "Trays on Shelf"
      expect(current_path).to eq(check_trays_new_path)
    end
  end
end
