require 'rails_helper'

feature "Bins", :type => :feature do
  include AuthenticationHelper

  describe "when signed in" do
    let(:shelf) { FactoryGirl.create(:shelf) }
    let(:tray) { FactoryGirl.create(:tray, shelf: shelf) }
    let(:item) { FactoryGirl.create(:item, tray: tray, thickness: 1) }
    let(:match) { FactoryGirl.create(:match, item: item) }
    let(:bin) { FactoryGirl.create(:bin, matches: [match], items: [item]) }


    before(:each) do
      login_user
      @bin = bin
    end

    after(:each) do
      Item.all.each do |item|
        item.destroy!
      end
      Match.all.each do |match|
        match.destroy!
      end
    end

    it "sees bins with matches in them" do
      visit bins_path
      expect(page).to have_content @bin.barcode
      expect(page).to have_content @bin.matches.count
      expect(page).to have_content @bin.updated_at
    end

    it "sees the contents of a bin" do
      visit show_bin_path(:id => @bin.id)
      expect(page).to have_content @bin.matches[0].item.barcode
      expect(page).to have_content @bin.matches[0].item.title
      expect(page).to have_content @bin.matches[0].item.author
    end

    it "can remove an item from a bin" do
      visit show_bin_path(:id => @bin.id)
      expect(page).to have_content @bin.matches[0].item.barcode
      expect(page).to have_content @bin.matches[0].item.title
      expect(page).to have_content @bin.matches[0].item.author
      click_button "Done"
      expect(current_path).to eq(show_bin_path(:id => @bin.id))
      expect(page).to have_content "Bin #{@bin.barcode} is empty."
    end

  end

end
