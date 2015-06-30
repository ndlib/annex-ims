require 'rails_helper'

def h
  Rails.application.routes.url_helpers
end

RSpec.describe ItemPath do
  let(:user) { instance_double(User, username: "bob", id: 1) }

  before(:each) do
    @tray = FactoryGirl.create(:tray)
    @tray2 = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray)
    @item2 = FactoryGirl.create(:item)

    item_uri = api_item_url(@item)
    item2_uri = api_item_url(@item2)

    stub_request(:get, item_uri).
      with(headers: { "User-Agent"=>"Faraday v0.9.1" }).
      to_return(status: 200, body: '{"path":"http://bogus", "sublibrary":"ANNEX"}', headers: {})

    stub_request(:get, item2_uri).
      with(headers: { "User-Agent"=>"Faraday v0.9.1" }).
      to_return(status: 200, body: '{"path":"http://bogus", "sublibrary":"ANNEX"}', headers: {})


    @user_id = 1 # Just fake having a user here
    allow(User).to receive(:find).and_return(user)
  end

  it "returns a path for a valid item" do
    results = ItemPath.call(@user_id, @item.id, @item.barcode)
    expect(results[:error]).to eq(nil)
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(h.show_item_path(:id => @item.id))
  end

  it "returns a path for a valid second item" do
    results = ItemPath.call(@user_id, @item.id, @item2.barcode)
    expect(results[:error]).to eq(nil)
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(h.show_item_path(:id => @item2.id))
  end

end
