# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportingController, type: :controller do
  let(:user) { FactoryBot.create(:user, admin: true) }
  let(:item) { FactoryBot.create(:item) }
  let(:tray) { FactoryBot.create(:tray) }
  let(:shelf) { FactoryBot.create(:shelf) }
  let(:bin) { FactoryBot.create(:bin) }

  before(:each) do
    sign_in(user)
  end

  describe 'POST' do
    context 'it is an Item barcode' do
      subject do
        post :call_report,
             params: {
               report: {
                 barcode: item.barcode
               }
             }
      end

      it 'redirects to item detail report' do
        expect(subject).to redirect_to item_detail_path(item.barcode)
      end
    end

    context 'it is a Tray barcode' do
        subject do
            post :call_report,
                 params: {
                   report: {
                     barcode: tray.barcode
                   }
                 }
          end
    
          it 'redirects to tray detail report' do
            expect(subject).to redirect_to tray_detail_path(tray.barcode)
          end
    end

    context 'it is a Shelf barcode' do
        subject do
            post :call_report,
                 params: {
                   report: {
                     barcode: shelf.barcode
                   }
                 }
          end
    
          it 'redirects to shelf detail report' do
            expect(subject).to redirect_to shelf_detail_path(shelf.barcode)
          end
    end

    context 'it is a Bin barcode' do
        subject do
            post :call_report,
                 params: {
                   report: {
                     barcode: bin.barcode
                   }
                 }
          end
    
          it 'redirects to bin detail report' do
            expect(subject).to redirect_to bin_detail_path(bin.barcode)
          end
    end
  end
end
