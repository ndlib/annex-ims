require 'rails_helper'

RSpec.describe UpdateController, type: :controller do
  let(:user) { FactoryBot.create(:user, admin: true) }
  let(:item) { FactoryBot.create(:item) }
  let(:new_item) { FactoryBot.build(:item) }

  before(:each) do
    sign_in(user)
    stub_api_item_metadata(barcode: new_item.barcode)
  end

  describe 'GET index' do
    context 'admin' do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'GET old' do
    context 'admin' do
      it 'redirects to show old item' do
        item
        get :old, old_barcode: item.barcode
        expect(response).to redirect_to(show_old_update_path(id: item.id))
      end
    end
  end

  describe 'GET new' do
    context 'admin' do
      it 'redirects to show new item' do
        item
        new_item
        get :new, old_barcode: item.barcode, new_barcode: new_item.barcode
        expect(response).to redirect_to(show_new_update_path(old_id: item.id, new_barcode: new_item.barcode))
      end
    end
  end
end
