require "rails_helper"

RSpec.describe TransfersController, type: :controller do
  let(:tray) { FactoryGirl.create(:tray, barcode: "TRAY-AL123") }
  let(:tray2) { FactoryGirl.create(:tray, barcode: "TRAY-AL456") }
  let(:tray3) { FactoryGirl.create(:tray, barcode: "TRAY-AL789") }
  let(:shelf) { FactoryGirl.create(:shelf, trays: [tray, tray3], barcode: "SHELF-AL123") }
  let(:shelf2) { FactoryGirl.create(:shelf, trays: [tray2], barcode: "SHELF-AL456") }
  let(:transfer) { FactoryGirl.create(:transfer, shelf: shelf, initiated_by: @user) }
  let(:transfer2) { FactoryGirl.create(:transfer, shelf: shelf2, initiated_by: @user) }

  before(:each) do
    @user = FactoryGirl.create(:user, admin: true)
    sign_in(@user)
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, id: transfer.id
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
      expect(assigns(:transfer)).to be_a_new(Transfer)
    end
  end

  describe "GET #view_active" do
    render_views

    it "returns list of active transfers" do
      transfer
      transfer2
      get :view_active
      expect(response).to have_http_status(:success)
      expect(response.body).to include(transfer.shelf.barcode)
    end
  end

  describe "POST #create" do
    it "initializes the correct shelf record" do
      shelf
      get :create, transfer: { shelf: { barcode: "SHELF-AL123" } }
      expect(assigns(:shelf)).to eq(shelf)
    end

    it "redirects to the transfer show page" do
      transfer
      get :create, transfer: { shelf: { barcode: "SHELF-AL123" } }
      expect(response).to redirect_to transfer_path(transfer.id)
    end
  end

  describe "PUT #scan_tray" do
    it "calls .check_for_blank_tray" do
      expect(controller).to receive(:check_for_blank_tray)
      put :scan_tray, id: transfer.id, tray: { barcode: "TRAY-AL123" }
      expect(assigns(:shelf)).to be_a_new(Shelf)
      expect(response).to have_http_status(:success)
    end

    it "calls .check_for_tray_membership" do
      expect(controller).to receive(:check_for_tray_membership)
      put :scan_tray, id: transfer.id, tray: { barcode: "TRAY-AL123" }
      expect(assigns(:shelf)).to be_a_new(Shelf)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT #transfer_tray" do
    it "calls .check_for_blank_shelf" do
      shelf2
      expect(controller).to receive(:check_for_blank_shelf).with("existing")
      put :transfer_tray, id: transfer.id, tray_id: tray.id, shelf: { barcode: "SHELF-AL456" }
      expect(response).to be_redirect
    end

    it "calls .dissociate_tray" do
      shelf2
      expect(controller).to receive(:dissociate_tray)
      put :transfer_tray, id: transfer.id, tray_id: tray.id, shelf: { barcode: "SHELF-AL456" }
      expect(response).to be_redirect
    end

    context "when shelf has remaining trays" do
      it "calls .check_for_final_tray" do
        shelf2
        put :transfer_tray, id: transfer.id, tray_id: tray.id, shelf: { barcode: "SHELF-AL456" }
        expect(response).to redirect_to transfer_path(transfer.id)
      end
    end

    context "when shelf is empty" do
      it "calls .check_for_final_tray" do
        shelf
        put :transfer_tray, id: transfer2.id, tray_id: tray2.id, shelf: { barcode: "SHELF-AL123" }
        expect(response).to redirect_to new_transfer_path
      end
    end
  end
end
