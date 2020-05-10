require 'rails_helper'

feature "Report Builder", type: :feature do
  include AuthenticationHelper

  describe "as a worker" do
    before(:each) do
      login_worker
      visit root_path
    end

    it "can see Report Builder in the menu" do
      click_link "Reports"
      expect(page).to have_content "Report Builder"
    end

    it "can access the Report Builder page" do
      click_link "Reports"
      click_link "Report Builder"
      expect(current_path).to eq(reports_path)
      expect(page).to have_content "Report Builder"
    end
  end
end
