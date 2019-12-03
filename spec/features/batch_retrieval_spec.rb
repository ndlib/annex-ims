require "rails_helper"

feature "Retrieve", type: :feature do
  include AuthenticationHelper

  describe "when signed in" do
    let(:shelf) { FactoryBot.create(:shelf) }
    let(:tray) { FactoryBot.create(:tray, shelf: shelf) }
    let(:item) { FactoryBot.create(:item, tray: tray, thickness: 1) }
    let(:request) { FactoryBot.create(:request) }
    let(:batch) { FactoryBot.create(:batch, user: @user) }
    let(:match) { FactoryBot.create(:match, batch: batch, request: request, item: item) }

    before(:each) do
      login_admin
      @match = match
    end

    after(:each) do
      ActivityLog.all.each(&:destroy!)
      Match.all.each(&:destroy!)
      Request.all.each(&:destroy!)
    end

    it "can see a match in the batch list" do
      visit retrieve_batch_path
      expect(page).to have_content match.item.title
    end

    it "rejects the wrong barcode" do
      visit retrieve_batch_path
      expect(page).to have_content match.item.title
      fill_in "Item", with: "TRAY"
      click_button "Save"
      expect(current_path).to eq(retrieve_batch_path)
      expect(page).to have_content "Wrong item scanned."
    end

    it "accepts the right barcode" do
      visit retrieve_batch_path
      expect(page).to have_content match.item.title
      fill_in "Item", with: match.item.barcode
      click_button "Save"
      expect(current_path).to eq(bin_batch_path)
      expect(page).to_not have_content "Wrong item scanned."
      expect(page).to have_content "Item #{match.item.barcode} scanned."
    end

    it "rejects a non-bin" do
      visit retrieve_batch_path
      expect(page).to have_content match.item.title
      fill_in "Item", with: match.item.barcode
      click_button "Save"
      expect(current_path).to eq(bin_batch_path)
      expect(page).to_not have_content "Wrong item scanned."
      expect(page).to have_content "Item #{match.item.barcode} scanned."
      fill_in "Bin", with: "TRAY"
      click_button "Save"
      expect(current_path).to eq(bin_batch_path)
      expect(page).to have_content "TRAY is not a bin, please try again."
    end

    it "rejects the wrong bin" do
      visit retrieve_batch_path
      expect(page).to have_content match.item.title
      fill_in "Item", with: match.item.barcode
      click_button "Save"
      expect(current_path).to eq(bin_batch_path)
      expect(page).to_not have_content "Wrong item scanned."
      expect(page).to have_content "Item #{match.item.barcode} scanned."
      fill_in "Bin", with: "BIN-ILL-SCAN-01"
      click_button "Save"
      expect(current_path).to eq(bin_batch_path)
      expect(page).to have_content "BIN-ILL-SCAN-01 is not the correct type, please try again."
    end

    it "accepts the right bin" do
      visit retrieve_batch_path
      expect(page).to have_content match.item.title
      fill_in "Item", with: match.item.barcode
      click_button "Save"
      expect(current_path).to eq(bin_batch_path)
      expect(page).to_not have_content "Wrong item scanned."
      expect(page).to have_content "Item #{match.item.barcode} scanned."
      fill_in "Bin", with: "BIN-#{match.request.bin_type}-01"
      click_button "Save"
      expect(page).to_not have_content "TRAY is not a bin, please try again."
      expect(page).to_not have_content "BIN-ILL-SCAN-01 is not the correct type, please try again."
      expect(page).to have_content "Item #{match.item.barcode} is now in bin BIN-#{match.request.bin_type}-01."
      expect(page).to have_content "#{@user.username} has an active batch, but it has no skipped items."
      expect(current_path).to eq(finalize_batch_path)
    end
  end
end
