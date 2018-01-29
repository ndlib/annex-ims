require 'rails_helper'

RSpec.describe UpdateController, type: :controller do
  let(:user) { FactoryGirl.create(:user, admin: true) }
  let(:item) { FactoryGirl.create(:item) }

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


  describe "GET old" do
    context "admin" do
      it "redirects to show old item" do
        item
        get :old, old_barcode: item.barcode  
        expect(response).to redirect_to(show_old_update_path(id: item.id))
      end
    end
  end
end
