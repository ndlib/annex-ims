require 'rails_helper'

def h
  Rails.application.routes.url_helpers
end

RSpec.describe ItemPath do
  before(:each) do
    @tray = FactoryGirl.create(:tray)
    @tray2 = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray)
    @item2 = FactoryGirl.create(:item)

    uri = Addressable::URI.parse "http://1.0/resources/items/record?auth_token=&barcode=#{@item.barcode}"
    uri2 = Addressable::URI.parse "http://1.0/resources/items/record?auth_token=&barcode=#{@item2.barcode}"

    stub_request(:get, uri).
         with(:headers => {'User-Agent'=>'Faraday v0.9.1'}).
         to_return(:status => 200, :body => '{"path":"http://bogus"}', :headers => {})

    stub_request(:get, uri2).
         with(:headers => {'User-Agent'=>'Faraday v0.9.1'}).
         to_return(:status => 200, :body => '{"path":"http://bogus"}', :headers => {})


    @user_id = 1 # Just fake having a user here
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
