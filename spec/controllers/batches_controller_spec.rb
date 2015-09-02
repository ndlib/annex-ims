require "rails_helper"

RSpec.describe BatchesController, type: :controller do
  let(:user) { FactoryGirl.create(:user, admin: true) }
  let(:batch) { FactoryGirl.create(:batch, user: user) }
  let(:match) { FactoryGirl.create(:match, batch: batch) }

  before(:each) do
    sign_in(user)
  end

  describe "GET item" do
    it "logs a SkippedItem activity on Skip" do
      allow_any_instance_of(Batch).to receive(:current_match).and_return(match)
      expect(ActivityLogger).to receive(:skip_item)
      get :item, commit: "Skip"
    end

    it "logs an AcceptedItem activity on Save" do
      allow_any_instance_of(Batch).to receive(:current_match).and_return(match)
      expect(ActivityLogger).to receive(:accept_item)
      get :item, commit: "Save", barcode: match.item.barcode
    end
  end

  describe "GET scan_bin" do
    it "logs a SkippedItem activity on Skip" do
      allow_any_instance_of(Batch).to receive(:current_match).and_return(match)
      expect(ActivityLogger).to receive(:skip_item)
      get :scan_bin, commit: "Skip"
    end
  end

  describe "remove match" do
    it "logs a RemovedMatch activity" do
      allow_any_instance_of(Batch).to receive(:current_match).and_return(match)
      expect(ActivityLogger).to receive(:remove_match)
      post :remove, commit: "Remove", match_id: match.id
    end
  end
end
