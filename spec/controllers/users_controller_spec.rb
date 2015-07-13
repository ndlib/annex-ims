require "rails_helper"

RSpec.describe UsersController, type: :controller do
  let(:user) { FactoryGirl.create(:user, id: 1, admin: true) }

  before(:each) do
    sign_in(user)
  end

  describe "PUT update" do
    it "sets admin to the value given" do
      expect_any_instance_of(User).to receive(:admin=).with(true)
      put :update, user_id: 1, admin: true
    end

    it "sets admin to the value given" do
      expect_any_instance_of(User).to receive(:admin=).with(false)
      put :update, user_id: 1, admin: false
    end

    it "sets admin to false if no value given" do
      expect_any_instance_of(User).to receive(:admin=).with(false)
      put :update, user_id: 1
    end
  end

  describe "PUT create" do
    it "creates the user" do
      expect(User).to receive(:new).with(username: "tester").and_return(user)
      put :create, user_name: "tester"
    end
  end
end
