require 'rails_helper'

feature "Items", :type => :feature do
  describe "when signed in" do
    before(:each) do
      # signin_user @user
      # pending "add user sign in code"
    end

    it "can scan a new item" do
      @item = FactoryGirl.create(:item, chron: 'TEST CHRON')
      visit items_path
      fill_in "Barcode", :with => @item.barcode
      click_button "Find"
      expect(current_path).to eq(show_item_path(:id => @item.id))
      expect(page).to have_content @item.title
      expect(page).to have_content @item.author
      expect(page).to have_content @item.chron
    end

  end
end
