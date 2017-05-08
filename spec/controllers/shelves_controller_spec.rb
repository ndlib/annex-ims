require 'rails_helper'

RSpec.describe ShelvesController, type: :controller do
  let(:user) { FactoryGirl.create(:user, admin: true) }

  before(:each) do
    sign_in(user)
  end

  describe 'POST scan' do
    it 'redirects' do
      post :scan, shelf: { barcode: 'SHELF-AL123' }
      expect(response).to be_redirect
      expect(response.location).to match(/shelves\/items\/\d+/)
    end

    it 'calls notify_airbrake on error and redirects to the trays path' do
      expect(controller).to receive(:notify_airbrake).with(kind_of(RuntimeError))
      post :scan, shelf: { barcode: '12345' }
      expect(response).to redirect_to(shelves_path)
    end
  end
end
