require "rails_helper"

feature "Shelves", type: :feature do
  include AuthenticationHelper

  describe "when signed in" do
    let!(:tray) { FactoryBot.create(:tray) }
    let!(:shelf) { FactoryBot.create(:shelf) }
    let!(:user) { FactoryBot.create(:user) }

    before(:each) do
      login_admin
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
