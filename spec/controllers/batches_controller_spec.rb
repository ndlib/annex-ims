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

  describe "#check_for_params" do
    it "calls a redirect when the param is blank" do
      expect(controller).to receive(:redirect_to)
      expect(controller.send(:check_for_params, nil))
    end
  end

  describe "#route_remove_request" do
    it "routes request to batches path when batch destroyed" do
      expect(controller).to receive(:redirect_to)
      expect(controller.send(:route_remove_request, "batch destroyed"))
      expect(flash[:notice]).to eq "Batch completed"
    end

    it "routes request to create batch path when batch not completed" do
      expect(controller).to receive(:redirect_to)
      expect(controller.send(:route_remove_request, nil))
      expect(flash[:notice]).to eq "Request removed"
    end
  end
end
