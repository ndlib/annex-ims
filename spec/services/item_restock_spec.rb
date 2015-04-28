require 'rails_helper'

def h
  Rails.application.routes.url_helpers
end

RSpec.describe ItemRestock do
  before(:each) do
    template = Addressable::Template.new "#{Rails.application.secrets.api_server}/1.0/resources/items/record?auth_token=#{Rails.application.secrets.api_token}&barcode={barcode}"
    stub_request(:get, template). with(:headers => {'User-Agent'=>'Faraday v0.9.1'}). to_return(:status => 200, :body => '{"item_id":"00110147500410","barcode":"00000016021933","bib_id":"001101475","sequence_number":"00410","admin_document_number":"001101475","call_number":"QH 573 .T746","description":"v.11 :no.1-6  \u003Cp.1-276\u003E   (2001:Jan.-June)","title":"Trends in cell biology.","author":"","publication":"Cambridge, UK : Elsevier Science Publishers, c1991-","edition":"","isbn_issn":"0962-8924","condition":null}', :headers => {})
    @user_id = 1 # Just fake having a user here
  end

=begin
  it "runs a test and expect errors" do
    item_id = "03117208667242"
    barcode = "examplebarcode"
    results = ItemRestock.call(item_id, barcode)
    expect(results[:error]).to eq("No item was found with barcode examplebarcode")
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(h.show_item_path(:id => item_id))
  end
=end

  it "scans an item and then switches to a different item" do
    @item = FactoryGirl.create(:item)
    @item2 = FactoryGirl.create(:item)
    results = ItemRestock.call(@user_id, @item.id, @item2.barcode)
    expect(results[:error]).to eq(nil)
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(h.show_item_path(:id => @item2.id))
  end

  it "stocks an item to a tray" do
    @tray = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray)
    results = ItemRestock.call(@user_id, @item.id, @tray.barcode)
    expect(results[:error]).to eq(nil)
    expect(results[:notice]).to eq("Item #{@item.barcode} stocked in #{@tray.barcode}.")
    expect(results[:path]).to eq(h.items_path)
  end

  it "rejects a wrong tray scan" do
    @tray = FactoryGirl.create(:tray)
    @tray2 = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray)
    results = ItemRestock.call(@user_id, @item.id, @tray2.barcode)
    expect(results[:error]).to eq("Item #{@item.barcode} is already assigned to #{@tray.barcode}.")
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(h.wrong_restock_path(:id => @item.id))
  end


  it "rejects scanning a shelf" do
    @tray = FactoryGirl.create(:tray)
    @shelf = FactoryGirl.create(:shelf)
    @item = FactoryGirl.create(:item, tray: @tray)
    results = ItemRestock.call(@user_id, @item.id, @shelf.barcode)
    expect(results[:error]).to eq("scan either a new item or a tray to stock to")
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(h.show_item_path(:id => @item.id))
  end


end
