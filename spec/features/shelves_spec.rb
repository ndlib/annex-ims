require "rails_helper"

feature "Shelves", type: :feature do
  include AuthenticationHelper

  describe "when signed in" do
    let!(:tray) { FactoryGirl.create(:tray) }
    let!(:shelf) { FactoryGirl.create(:shelf) }
    let!(:user) { FactoryGirl.create(:user) }

    before(:each) do
      login_user
    end

    context "shelf details" do
      it "displays the shelf details" do
        visit shelf_detail_path(shelf.barcode)
        expect(page).to have_content shelf.barcode
        expect(page).to have_content shelf.size
      end
    end
  end
end
