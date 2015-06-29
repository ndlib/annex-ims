require 'rails_helper'

RSpec.describe WelcomeController, :type => :controller do

  describe "GET index" do
    it "redirects to login" do
      expect(get :index).to redirect_to(new_user_session_path)
    end
  end

end
