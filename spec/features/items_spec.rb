require 'rails_helper'

feature "Items", :type => :feature do

  describe "when signed in" do
    before(:each) do
      item = FactoryGirl.create(:item, :barcode => 'ITEM-1234')
      # signin_user @user
      # pending "add user sign in code"
    end

    it "can scan a new item" do
      visit items_path
      fill_in "Barcode", :with => 'ITEM-1234'
      click_button "Save"
    end

  end

  describe "when not signed in" do
    pending "add some scenarios (or delete) #{__FILE__}"
  end
end
