require 'rails_helper'

RSpec.describe DeaccessioningController, type: :controller do
  let(:user) { FactoryGirl.create(:user, admin: true) }
  let(:item) { FactoryGirl.create(:item, status: 0) }
  let(:unstock) { FactoryGirl.create(:item, status: 1) }
  let!(:disposition) { FactoryGirl.create(:disposition) }
  let!(:comment) { "Test comment" }

  before(:each) do
    sign_in(user)
  end

  describe "GET index" do
    context "admin" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST req" do
    it "associates an unstocked item with a special bin" do
      post :req, items: {"#{unstock.id}" => "items[#{unstock.id}]"},
	   disposition_id: disposition.id,
           comment: comment
      bin = GetBinFromBarcode.call("BIN-DEAC-HAND-01")
      i = Item.find(unstock.id)
      expect(i.bin).to eq(bin)
    end

    it "redirects to batches path" do
      subject
      expect(response).to redirect_to(batches_path)
    end

    subject do
      post :req, items: {"#{item.id}" => "items[#{item.id}]"},
	   disposition_id: disposition.id,
           comment: comment
    end
    it "builds a deaccessioning request" do
      expect(BuildDeaccessioningRequest).to receive(:call).
        with(item.id.to_s, disposition.id.to_s, comment).
        and_return([])
      subject
    end

    it "redirects to batches path" do
      subject
      expect(response).to redirect_to(batches_path)
    end
  end

  describe "POST req (empty)" do
    subject do
      post :req, items: {}
    end

    it "redirects to deaccessioning path" do
      subject
      expect(response).to redirect_to(deaccessioning_path)
    end
  end
end
