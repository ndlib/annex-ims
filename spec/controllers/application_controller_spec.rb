require "rails_helper"


RSpec.describe ApplicationController, type: :controller do
  controller do
    def dummy
      render nothing: true
    end
  end
  let(:user) { FactoryGirl.create(:user) }

  before(:each) do
    sign_in(user)
    routes.draw { get "dummy" => "anonymous#dummy" }
  end

  context "user is not an admin" do
    let(:user) { FactoryGirl.create(:user, admin: false) }

    it "throws a routing error" do
      expect{ get "dummy" }.to raise_error(ActionController::RoutingError)
    end
  end

  context "user is an admin" do
    let(:user) { FactoryGirl.create(:user, admin: true) }

    it "does not throw a routing error" do
      expect{ get "dummy" }.not_to raise_error
    end
  end
end
