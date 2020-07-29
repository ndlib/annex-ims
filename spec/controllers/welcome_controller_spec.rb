# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  describe 'GET index' do
    it 'redirects to login' do
      expect(get(:index)).to redirect_to(user_oktaoauth_omniauth_authorize_path)
    end
  end
end
