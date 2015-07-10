require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render text: "index"
    end
  end

  context "user" do
    let(:user) { FactoryGirl.create(:user) }

    before(:each) do
      sign_in(user)
    end

    context "is not an admin" do
      let(:user) { FactoryGirl.create(:user, admin: false) }

      it "throws a routing error" do
        expect { get :index }.to raise_error(ActionController::RoutingError)
      end
    end

    context "is an admin" do
      let(:user) { FactoryGirl.create(:user, admin: true) }

      it "renders" do
        get :index
        expect(response).to be_success
        expect(response.body).to eq("index")
      end
    end
  end

  context "no user" do
    it "redirects the user to sign in" do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
