require 'rails_helper'

feature "Bins", :type => :feature do
  include AuthenticationHelper

  describe "when signed in" do
    let(:shelf) { FactoryBot.create(:shelf) }
    let(:tray) { FactoryBot.create(:tray, shelf: shelf) }
    let(:item) { FactoryBot.create(:item, tray: tray, thickness: 1) }
    let(:bin) { FactoryBot.create(:bin, items: [item]) }
    let(:match) { FactoryBot.create(:match, item: item, bin: bin) }


    before(:each) do
      login_admin

      @bin = bin
      @match = match

      stub_request(:post, api_send_url). with(:body => {"barcode"=>"#{@match.item.barcode}", "delivery_type"=>"send", "item_id"=>"#{@match.item.id}", "request_type"=>"doc_del", "source"=>"aleph", "transaction_num"=>"", "tray_code"=>"#{@match.item.tray.barcode}"}, :headers => {'User-Agent'=>'Faraday v0.17.0'}). to_return{ |response| { :status => 200, :body => {:results => {:status => "OK", :message => "Item stocked"}}.to_json, :headers => {} } }

    end

    after(:each) do
      ActivityLog.all.each do |log|
        log.destroy!
      end
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
      expect(page).to have_content @bin.updated_at.strftime("%m-%d-%Y %I:%M%p")
    end

    it "sees the contents of a bin" do
      visit show_bin_path(:id => @bin.id)
      expect(page).to have_content @bin.matches[0].item.barcode
      expect(page).to have_content @bin.matches[0].item.title
      expect(page).to have_content @bin.matches[0].item.author
    end

    it "can remove an item from a bin" do
      stub_api_scan_send(match: @bin.matches[0])
      visit show_bin_path(:id => @bin.id)
      expect(page).to have_content @bin.matches[0].item.barcode
      expect(page).to have_content @bin.matches[0].item.title
      expect(page).to have_content @bin.matches[0].item.author
      click_button "Done"
      expect(current_path).to eq(show_bin_path(:id => @bin.id))
      expect(page).to have_content "Bin #{@bin.barcode} is empty."
    end

    it "persists the entries shown for all bins", js: true do
      visit bins_path
      expect(page).to have_content "Show"
      select "100", from: "bins_length", visible: false
      visit root_path
      visit bins_path
      expect(page).to have_select('bins_length', selected: '100')
    end

    it "persists the entries shown for a single bin", js: true do
      visit show_bin_path(:id => @bin.id)
      expect(page).to have_content "Show"
      select "100", from: "matches_length", visible: false
      visit root_path
      visit show_bin_path(:id => @bin.id)
      expect(page).to have_select('matches_length', selected: '100')
    end

  end

end
