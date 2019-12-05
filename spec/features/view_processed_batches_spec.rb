require "rails_helper"

feature "View Processed", type: :feature do
  include AuthenticationHelper

  describe "when signed in" do
    let(:shelf) { FactoryBot.create(:shelf) }
    let(:tray) { FactoryBot.create(:tray, shelf: shelf) }
    let(:item) { FactoryBot.create(:item, tray: tray, thickness: 1) }
    let(:request) { FactoryBot.create(:request) }
    let(:batch) { FactoryBot.create(:batch, user: @user, active: false) }
    let(:match) { FactoryBot.create(:match, batch: batch, request: request, item: item) }

    before(:each) do
      login_admin
      @match = match
    end

    it "can see processed batches" do
      visit view_processed_batches_path
      expect(page).to have_content @match.batch.id
      expect(page).to have_content @match.batch.user.username
      expect(page).to have_content @match.batch.updated_at.strftime("%m-%d-%Y %I:%M%p")
    end

    it "can see details of a processed batch" do
      visit view_single_processed_batch_path(id: @match.batch.id)
      expect(page).to have_content @match.batch.requests[0].title
      expect(page).to have_content @match.batch.requests[0].author
      expect(page).to have_content @match.batch.requests[0].source
      expect(page).to have_content @match.batch.requests[0].del_type
    end
  end
end
