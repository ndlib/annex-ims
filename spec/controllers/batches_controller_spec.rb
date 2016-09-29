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

  describe "GET index" do
    subject { get :index }

    context 'when the user has a batch' do
      let(:batch) { FactoryGirl.create(:batch, user: user) }

      it 'redirects to current batch' do
        expect(subject).to redirect_to(current_batch_path)
      end

      it 'assigns data for the view' do
        subject
        expect(assigns(:data)).to eq([])
      end
    end

    context 'when the user has no batch' do
      let(:batch) { FactoryGirl.create(:batch) }

      it 'renders index view' do
        subject
        expect(response).to render_template(:index)
      end
    end
  end

  describe "POST create" do
    subject { post :create, "commit"=>"Save", "batch"=>["69-156", "70-196"] }

    context 'when the user has a batch' do
      let(:batch) { FactoryGirl.create(:batch, user: user) }

      it 'redirects to current batch' do
        expect(subject).to redirect_to(current_batch_path)
      end
    end

    context 'when the user has no batch' do
      let(:batch) { FactoryGirl.create(:batch) }

      it 'uses BuildBatch to create the batch' do
        expect(BuildBatch).to receive(:call).with(["69-156", "70-196"], user)
        subject
      end

      it 'redirects to root' do
        allow(BuildBatch).to receive(:call).and_return(nil)
        expect(subject).to redirect_to(root_path)
      end
    end

    context 'when batch is empty' do
      subject { post :create, "commit"=>"Save" }

      it 'redirects to batches' do
        expect(subject).to redirect_to(batches_path)
      end
    end
  end

  describe "GET current" do
    subject { get :current }

    context 'when the user has a batch' do
      let(:batch) { FactoryGirl.create(:batch, user: user) }

      it 'renders current view' do
        subject
        expect(response).to render_template(:current)
      end

      it 'assigns batch for the view' do
        subject
        expect(assigns(:batch)).to eq(batch)
      end
    end

    context 'when the user has no batch' do
      let(:batch) { FactoryGirl.create(:batch) }

      it 'redirects to batches' do
        expect(subject).to redirect_to(batches_path)
      end
    end
  end

  describe "POST remove" do
    context 'when match id is given' do
      subject { post :remove, match_id: match.id, commit: "Remove" }

      it 'calls DestroyMatch' do
        expect(DestroyMatch).to receive(:call).with(match: match, user: user)
        subject
      end

      it 'calls DissociateItemFromBin' do
        expect(DissociateItemFromBin).to receive(:call).with(item: item, user: user)
        subject
      end

      it 'calls FinishBatch' do
        expect(FinishBatch).to receive(:call).with(batch, user)
        subject
      end

      it 'redirects to current batch' do
        expect(subject).to redirect_to(current_batch_path)
      end
    end

    context 'when match id is not given' do
      subject { post :remove, commit: "Remove" }

      it 'does not call DestroyMatch' do
        expect(DestroyMatch).not_to receive(:call)
        subject
      end

      it 'does not call DissociateItemFromBin' do
        expect(DissociateItemFromBin).not_to receive(:call)
        subject
      end

      it 'does not call FinishBatch' do
        expect(FinishBatch).not_to receive(:call)
        subject
      end

      it 'redirects to current batch' do
        expect(subject).to redirect_to(current_batch_path)
      end
    end
  end

  describe "GET retrieve" do
    subject { get :retrieve }

    context 'when the user has no batch' do
      let(:batch) { FactoryGirl.create(:batch) }

      it 'redirects to batches' do
        expect(subject).to redirect_to(batches_path)
      end
    end

    context 'when the user has a batch' do
      let(:batch) { FactoryGirl.create(:batch, user: user) }

      it 'assigns the match for the view' do
        subject
        expect(assigns(:match)).to eq(match)
      end

      context 'but there are no remaining unprocessed matches' do
        let(:match) { FactoryGirl.create(:match, item: item, batch: batch, processed: "accepted") }

        it 'redirects to finalize batch' do
          expect(subject).to redirect_to(finalize_batch_path)
        end
      end
    end
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

  describe "GET bin" do
    subject { get :bin }

    context 'when the user has no batch' do
      let(:batch) { FactoryGirl.create(:batch) }

      it 'redirects to batches' do
        expect(subject).to redirect_to(batches_path)
      end
    end

    context 'when the user has a batch' do
      let(:batch) { FactoryGirl.create(:batch, user: user) }

      it 'renders bin view' do
        subject
        expect(response).to render_template(:bin)
      end

      it 'assigns batch for the view' do
        subject
        expect(assigns(:batch)).to eq(batch)
      end

      it 'assigns match for the view' do
        subject
        expect(assigns(:match)).to eq(match)
      end
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
