require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  controller do
    def index
      render text: "index"
    end
  end

  context "user" do
    before(:each) do
      sign_in(user)
    end

    context "is not an admin" do
      let(:user) { FactoryGirl.create(:user, admin: false, last_activity_at: Time.now) }

      it "throws a routing error" do
        expect { get :index }.to raise_error(ActionController::RoutingError)
      end
    end

    context "is not a worker" do
      let(:user) { FactoryGirl.create(:user, worker: false, last_activity_at: Time.now) }

      it "throws a routing error" do
        expect { get :index }.to raise_error(ActionController::RoutingError)
      end
    end

    context "is an admin" do
      let(:user) { FactoryGirl.create(:user, admin: true, last_activity_at: Time.now) }

      it "renders" do
        get :index
        expect(response).to be_success
        expect(response.body).to eq("index")
      end

      it "checks if the user session is expired" do
        expect(IsUserSessionExpired).to receive(:call)
        get :index
      end
    end

    context "is a worker" do
      let(:user) { FactoryGirl.create(:user, worker: true, last_activity_at: Time.now) }

      it "renders" do
        get :index
        expect(response).to be_success
        expect(response.body).to eq("index")
      end

      it "checks if the user session is expired" do
        expect(IsUserSessionExpired).to receive(:call)
        get :index
      end
    end
  end

  context "no user" do
    it "redirects the user to sign in" do
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "admin user session has not expired" do
    let(:user) { FactoryGirl.create(:user, admin: true, last_activity_at: Time.now) }

    before(:each) do
      sign_in(user)
    end

    it "renders index" do
      get :index
      expect(response.body).to eq("index")
    end

    it "updates the activity" do
      expect(subject).to receive(:update_activity)
      get :index
    end
  end

  context "worker user session has not expired" do
    let(:user) { FactoryGirl.create(:user, worker: true, last_activity_at: Time.now) }

    before(:each) do
      sign_in(user)
    end

    it "renders index" do
      get :index
      expect(response.body).to eq("index")
    end

    it "updates the activity" do
      expect(subject).to receive(:update_activity)
      get :index
    end
  end

  context "admin user session has expired" do
    let(:user) { FactoryGirl.create(:user, admin: true, last_activity_at: Time.now - 2.days) }

    before(:each) do
      sign_in(user)
    end

    it "does not render index" do
      get :index
      expect(response.body).to eq("")
    end

    it "does not update the activity" do
      expect(subject).not_to receive(:update_activity)
      get :index
    end
  end

  context "worker user session has expired" do
    let(:user) { FactoryGirl.create(:user, worker: true, last_activity_at: Time.now - 2.days) }

    before(:each) do
      sign_in(user)
    end

    it "does not render index" do
      get :index
      expect(response.body).to eq("")
    end

    it "does not update the activity" do
      expect(subject).not_to receive(:update_activity)
      get :index
    end
  end
end
