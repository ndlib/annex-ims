require 'rails_helper'

def h
  Rails.application.routes.url_helpers
end

RSpec.describe ItemRestock do
  before(:each) do
    @tray = FactoryGirl.create(:tray)
    @shelf = FactoryGirl.create(:shelf)
    @tray2 = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray)
    @item2 = FactoryGirl.create(:item)
    @user = FactoryGirl.create(:user)

    item_uri = api_item_url(@item)
    item2_uri = api_item_url(@item2)

    stub_request(:post, api_stock_url).
      with(:body => {"barcode"=>"#{@item.barcode}", "item_id"=>"#{@item.id}", "tray_code"=>"#{@item.tray.barcode}"},
        :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.15.3'}).
      to_return{ |response| { :status => 200, :body => {:results => {:status => "OK", :message => "Item stocked"}}.to_json, :headers => {} } }

    response_body = api_fixture_data("item_metadata.json")

    stub_request(:get, item_uri).
      with(headers: { "User-Agent" => "Faraday v0.15.3" }).
      to_return(status: 200, body: response_body, headers: {})

    stub_request(:get, item2_uri).
      with(headers: { "User-Agent" => "Faraday v0.15.3" }).
      to_return(status: 200, body: response_body, headers: {})

    @user_id = 1 # Just fake having a user here
  end

  it "scans an item and then switches to a different item" do
    results = ItemRestock.call(@user.id, @item.id, @item2.barcode)
    expect(results[:error]).to eq(nil)
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(h.show_item_path(:id => @item2.id))
  end

  it "stocks an item to a tray" do
    results = ItemRestock.call(@user.id, @item.id, @tray.barcode)
    expect(results[:error]).to eq(nil)
    expect(results[:notice]).to eq("Item #{@item.barcode} stocked in #{@tray.barcode}.")
    expect(results[:path]).to eq(h.items_path)
  end

  it "rejects a wrong tray scan" do
    results = ItemRestock.call(@user.id, @item.id, @tray2.barcode)
    expect(results[:error]).to eq("Item #{@item.barcode} is already assigned to #{@tray.barcode}.")
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(h.wrong_restock_path(:id => @item.id))
  end


  it "rejects scanning a shelf" do
    results = ItemRestock.call(@user_id, @item.id, @shelf.barcode)
    expect(results[:error]).to eq("scan either a new item or a tray to stock to")
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(h.show_item_path(:id => @item.id))
  end


end
