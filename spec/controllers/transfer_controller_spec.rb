require "rails_helper"

RSpec.describe TransfersController, type: :controller do
  let(:tray) { FactoryBot.create(:tray, barcode: "TRAY-AL123") }
  let(:tray2) { FactoryBot.create(:tray, barcode: "TRAY-AL456") }
  let(:tray3) { FactoryBot.create(:tray, barcode: "TRAY-AL789") }
  let(:shelf) { FactoryBot.create(:shelf, trays: [tray, tray3], barcode: "SHELF-AL123") }
  let(:shelf2) { FactoryBot.create(:shelf, trays: [tray2], barcode: "SHELF-AL456") }
  let(:shelf3) { FactoryBot.create(:shelf, trays: [], barcode: "SHELF-AL789") }
  let(:transfer) { FactoryBot.create(:transfer, shelf: shelf, initiated_by: @user) }
  let(:transfer2) { FactoryBot.create(:transfer, shelf: shelf2, initiated_by: @user) }

  before(:each) do
    @user = FactoryBot.create(:user, admin: true)
    sign_in(@user)
  end

  describe "GET #show" do
    it "returns http success" do
      get :show, params: { id: transfer.id }
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
      get :create, params: { transfer: { shelf: { barcode: "SHELF-AL123" } } }
      expect(assigns(:shelf)).to eq(shelf)
    end

    it "redirects to the transfer show page" do
      transfer
      get :create, params: { transfer: { shelf: { barcode: "SHELF-AL123" } } }
      expect(response).to redirect_to transfer_path(transfer.id)
    end
  end

  describe "PUT #scan_tray" do
    it "calls .check_for_blank_tray" do
      expect(controller).to receive(:check_for_blank_tray)
      put :scan_tray, params: { id: transfer.id, tray: { barcode: "TRAY-AL123" } }
      expect(assigns(:shelf)).to be_a_new(Shelf)
      expect(response).to have_http_status(:success)
    end

    it "calls .check_for_tray_membership" do
      expect(controller).to receive(:check_for_tray_membership)
      put :scan_tray, params: { id: transfer.id, tray: { barcode: "TRAY-AL123" } }
      expect(assigns(:shelf)).to be_a_new(Shelf)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PUT #transfer_tray" do
    it "calls .check_for_blank_shelf" do
      shelf2
      put :transfer_tray, params: { id: transfer.id, tray_id: tray.id, shelf: { barcode: "SHELF-AL456" } }
      expect(response).to be_redirect
    end

    it "calls .dissociate_tray" do
      shelf2
      expect(controller).to receive(:dissociate_tray)
      put :transfer_tray, params: { id: transfer.id, tray_id: tray.id, shelf: { barcode: "SHELF-AL456" } }
      expect(response).to be_redirect
    end

    context "when shelf has remaining trays" do
      it "calls .check_for_final_tray" do
        shelf2
        put :transfer_tray, params: { id: transfer.id, tray_id: tray.id, shelf: { barcode: "SHELF-AL456" } }
        expect(response).to redirect_to transfer_path(transfer.id)
      end
    end

    context "when shelf is empty" do
      it "calls .check_for_final_tray" do
        shelf
        put :transfer_tray, params: { id: transfer2.id, tray_id: tray2.id, shelf: { barcode: "SHELF-AL123" } }
        expect(response).to redirect_to new_transfer_path
      end
    end
  end

  describe "DELETE #destroy_transfer" do
    it "deletes one transfer record" do
      transfer
      transfer2
      expect(Transfer.all.count).to eq 2
      delete :destroy, params: { id: transfer2.id }
      expect(Transfer.all.count).to eq 1
    end

    it "redirects to active transfer page" do
      transfer
      transfer2
      delete :destroy, params: { id: transfer2.id }
      expect(response).to redirect_to view_active_transfers_path
    end

    it "displays error when transfer not deleted" do
      expect(DestroyTransfer).to receive(:call).and_return(false)
      delete :destroy, params: { id: transfer2.id }
      expect(flash[:error]).to be_present
    end

    it "displays notice when transfer deleted" do
      expect(DestroyTransfer).to receive(:call).and_return("success")
      delete :destroy, params: { id: transfer2.id }
      expect(flash[:notice]).to be_present
    end
  end

  describe "#assign_error_message" do
    context "when type is 'tray_blank'" do
      it "returns tray does not exist message" do
        return_message = "Tray with barcode #{tray.barcode} does not exist."
        expect(controller.send(:assign_error_message, "tray_blank", tray)).to eq return_message
      end
    end

    context "when type is 'tray_not_associated'" do
      it "returns tray not associated message" do
        return_message = "Tray with barcode #{tray.barcode} is not accociated with this shelf. Rescan tray."
        expect(controller.send(:assign_error_message, "tray_not_associated", tray)).to eq return_message
      end
    end
  end

  describe "#check_for_blank_tray" do
    it "assigns error message when tray blank" do
      controller.instance_variable_set :@tray, Tray.where(barcode: "TRAY-999999").take
      expect(controller).to receive(:assign_error_message).with("tray_blank", @tray)
      expect(controller).to receive(:redirect_to).with(any_args).and_return(nil)
      expect(controller).to receive(:transfer_path).with(any_args).and_return(nil)
      controller.send(:check_for_blank_tray)
    end
  end

  describe "#check_for_tray_membership" do
    it "assigns error message when tray not assigned to shelf" do
      controller.instance_variable_set :@tray, Tray.where(barcode: "TRAY-999999").take
      controller.instance_variable_set :@transfer, transfer
      expect(controller).to receive(:assign_error_message).with("tray_not_associated", @tray)
      expect(controller).to receive(:redirect_to).with(any_args).and_return(nil)
      expect(controller).to receive(:transfer_path).with(any_args).and_return(nil)
      controller.send(:check_for_tray_membership)
    end
  end

  describe "#check_for_blank_shelf" do
    context "when type is not new" do
      it "redirects back to transfer path" do
        controller.instance_variable_set :@shelf, Shelf.where(barcode: "SHELF-999999").take
        controller.instance_variable_set :@transfer, transfer
        allow(controller).to receive(:params).and_return(transfer: { shelf: { barcode: "SHELF-999999" } }, id: transfer.id)
        expect(controller).to receive(:redirect_to).with(transfer_path(id: transfer.id))
        controller.send(:check_for_blank_shelf, "existing")
      end
    end

    context "when type is new" do
      it "redirects to new transfer path" do
        controller.instance_variable_set :@shelf, Shelf.where(barcode: "SHELF-999999").take
        controller.instance_variable_set :@transfer, transfer
        allow(controller).to receive(:params).and_return(transfer: { shelf: { barcode: "SHELF-999999" } }, id: transfer.id)
        expect(controller).to receive(:redirect_to).with(new_transfer_path)
        controller.send(:check_for_blank_shelf, "new")
      end
    end
  end

  describe "#check_for_trays" do
    context "when tray count is zero" do
      it "redirects to new transfer path" do
        shelf3
        controller.instance_variable_set :@shelf, Shelf.where(barcode: "SHELF-AL789").take
        expect(controller).to receive(:redirect_to).with(new_transfer_path)
        controller.send(:check_for_trays)
      end
    end
  end
end
