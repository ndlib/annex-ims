require 'rails_helper'

RSpec.describe DeaccessioningController, type: :controller do
  let(:user) { FactoryGirl.create(:user, admin: true) }

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
end
