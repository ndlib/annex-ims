require "rails_helper"

RSpec.describe BatchesController, type: :controller do
  let(:user) { FactoryGirl.create(:user, admin: true) }
  let(:batch) { FactoryGirl.create(:batch, user: user) }
  let(:item) { FactoryGirl.create(:item) }
  let(:match) { FactoryGirl.create(:match, batch: batch, item: item) }

  before(:each) do
    sign_in(user)
    match
  end

  describe "GET item" do
    subject { get :item, match_id: match.id }

    context "skipping an item" do
      subject { get :item, commit: "Skip", match_id: match.id }
      it "logs a SkippedItem activity on Skip" do
        allow_any_instance_of(Batch).to receive(:current_match).and_return(match)
        expect(ActivityLogger).to receive(:skip_item)
        subject
      end
    end

    context "saving an item" do
      subject { get :item, commit: "Save", barcode: match.item.barcode, match_id: match.id }
      it "logs an AcceptedItem activity on Save" do
        allow_any_instance_of(Batch).to receive(:current_match).and_return(match)
        expect(ActivityLogger).to receive(:accept_item)
        subject
      end
    end

    it "requires admin permissions" do
      expect_any_instance_of(described_class).to receive(:require_admin)
      subject
    end
  end

  describe "GET scan_bin" do
    subject { get :scan_bin, match_id: match.id }

    context "when there is no batch for the user" do
      let(:batch) { FactoryGirl.create(:batch) }

      it 'flashes an error message' do
        subject
        expect(flash[:error]).to eq("#{user.username} does not have an active batch, please create one.")
      end

      it 'redirects to bin batch' do
        expect(subject).to redirect_to(batches_path)
      end
    end

    context "skipping scan_bin" do
      subject { get :scan_bin, commit: "Skip", match_id: match.id }

      it "logs a SkippedItem activity on Skip" do
        expect(ActivityLogger).to receive(:skip_item)
        subject
      end
    end

    it "requires admin permissions" do
      expect_any_instance_of(described_class).to receive(:require_admin)
      subject
    end
  end

  describe "remove match" do
    subject { post :remove, commit: "Remove", match_id: match.id }

    context "destroying the match" do
      it "uses DestroyMatch" do
        allow_any_instance_of(Batch).to receive(:current_match).and_return(match)
        expect(DestroyMatch).to receive(:call).with(match: match, user: user)
        subject
      end
    end

    context "dissociating the item" do
      it "trys to dissociate the item from the bin" do
        expect(DissociateItemFromBin).to receive(:call).with(item: match.item, user: user)
        subject
      end
    end

    context "finishing the batch" do
      it "trys to finish the batch" do
        expect(FinishBatch).to receive(:call).with(match.batch, user)
        subject
      end
    end

    it "requires admin permissions" do
      expect_any_instance_of(described_class).to receive(:require_admin)
      subject
    end
  end
end
