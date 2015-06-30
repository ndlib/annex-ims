require 'rails_helper'

RSpec.describe StockItem do
  subject { described_class.call(@item, @user)}

  before(:each) do
    @tray = FactoryGirl.create(:tray)
    @shelf = FactoryGirl.create(:shelf)
    @tray2 = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray, thickness: 1)
    @item2 = FactoryGirl.create(:item, thickness: 1)
    @user = FactoryGirl.create(:user)

    stub_request(:post, api_stock_url).
      with(:body => {"barcode"=>"#{@item.barcode}", "item_id"=>"#{@item.id}", "tray_code"=>"#{@item.tray.barcode}"},
        :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.9.1'}).
      to_return{ |response| { :status => 200, :body => {:results => {:status => "OK", :message => "Item stocked"}}.to_json, :headers => {} } }
  end

  it "sets stocked" do
    expect(@item).to receive("stocked!")
    subject
  end

  it "returns the item when it is successful" do
    allow(@item).to receive(:save).and_return(true)
    expect(subject).to be(@item)
  end

  it "returns false when it is unsuccessful" do
    allow(@item).to receive("save!").and_return(false)
    expect(subject).to be(false)
  end

  it "queues a background job" do
    expect(ApiStockItemJob).to receive(:perform_later).with(item: @item)
    subject
  end
end
