require 'rails_helper'

def h
  Rails.application.routes.url_helpers
end

RSpec.describe ItemRestockToTray do
  before(:each) do

  end

  it "runs a test and expect errors" do
    @item = FactoryGirl.create(:item)
    barcode = "TRAY-AL1234"
    results = ItemRestockToTray.call(@item.id, barcode)
    expect(results[:error]).to eq("This item has no tray to stock to.")
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(h.show_item_path(:id => @item.id))
  end

  it "stocks an item to a tray" do
    @tray = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray)
    results = ItemRestockToTray.call(@item.id, @tray.barcode)
    expect(results[:error]).to eq(nil)
    expect(results[:notice]).to eq("Item #{@item.barcode} stocked in #{@tray.barcode}.")
    expect(results[:path]).to eq(h.items_path)
  end

  it "rejects a wrong tray scan" do
    @tray = FactoryGirl.create(:tray)
    @tray2 = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray)
    results = ItemRestockToTray.call(@item.id, @tray2.barcode)
    expect(results[:error]).to eq("Item #{@item.barcode} is already assigned to #{@tray.barcode}.")
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(h.wrong_restock_path(:id => @item.id))
  end

end
