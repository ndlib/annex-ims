require 'rails_helper'

feature "Bins", :type => :feature do
  include AuthenticationHelper

  describe "when signed in" do
    let(:shelf) { FactoryGirl.create(:shelf) }
    let(:tray) { FactoryGirl.create(:tray, shelf: shelf) }
    let(:item) { FactoryGirl.create(:item, tray: tray, thickness: 1) }
    let(:bin) { FactoryGirl.create(:bin, items: [item]) }
    let(:match) { FactoryGirl.create(:match, item: item, bin: bin) }


    before(:each) do
      login_user

      @bin = bin
      @match = match

      template = Addressable::Template.new "#{Rails.application.secrets.api_server}/1.0/resources/items/send?auth_token=#{Rails.application.secrets.api_token}"
      stub_request(:post, template). with(:body => {"barcode"=>"#{@match.item.barcode}", "delivery_type"=>"send", "item_id"=>"#{@match.item.id}", "request_type"=>"doc_del", "source"=>"aleph", "transaction_num"=>"", "tray_code"=>"#{@match.item.tray.barcode}"}, :headers => {'User-Agent'=>'Faraday v0.9.1'}). to_return{ |response| { :status => 200, :body => {:results => {:status => "OK", :message => "Item stocked"}}.to_json, :headers => {} } }

    end

    after(:each) do
      Item.all.each do |item|
        item.destroy!
      end
      Match.all.each do |match|
        match.destroy!
      end
    end

    it "sees bins with matches in them" do
      visit bins_path
      expect(page).to have_content @bin.barcode
      expect(page).to have_content @bin.matches.count
      expect(page).to have_content @bin.updated_at
    end

    it "sees the contents of a bin" do
      visit show_bin_path(:id => @bin.id)
      expect(page).to have_content @bin.matches[0].item.barcode
      expect(page).to have_content @bin.matches[0].item.title
      expect(page).to have_content @bin.matches[0].item.author
    end

    it "can remove an item from a bin" do
      visit show_bin_path(:id => @bin.id)
      expect(page).to have_content @bin.matches[0].item.barcode
      expect(page).to have_content @bin.matches[0].item.title
      expect(page).to have_content @bin.matches[0].item.author
      click_button "Done"
      expect(current_path).to eq(show_bin_path(:id => @bin.id))
      expect(page).to have_content "Bin #{@bin.barcode} is empty."
    end

  end

end
