require 'rails_helper'

RSpec.describe TraysController, :type => :controller do

  before(:each) do
    @user = FactoryGirl.create(:user, admin: true)
    sign_in(@user)
  end

  describe "GET index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST scan" do
    it "redirects" do
      post :scan, tray: { barcode: "TRAY-AL123" }
      expect(response).to be_redirect
      expect(response.location).to match(/trays\/shelves\/\d+/)
    end

    it "calls notify_airbrake on error and redirects to the trays path" do
      expect(controller).to receive(:notify_airbrake).with(kind_of(RuntimeError))
      post :scan, tray: { barcode: "12345" }
      expect(response).to redirect_to(trays_path)
    end
  end
end
