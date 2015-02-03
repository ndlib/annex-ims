require 'rails_helper'

RSpec.describe ItemMultiplex do
  before(:each) do

  end

  it "runs a test and expect errors" do
    item_id = "03117208667242"
    barcode = "examplebarcode"
    results = ItemMultiplex.call(item_id, barcode)
    expect(results[:error]).to eq("No item was found with barcode examplebarcode")
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(show_item_path(:id => item_id))
  end

  it "scans an item and then switches to a different item" do
    @item = FactoryGirl.create(:item)
    @item2 = FactoryGirl.create(:item)
    results = ItemMultiplex.call(@item.id, @item2.barcode)
    expect(results[:error]).to eq(nil)
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(show_item_path(:id => @item2.id))
  end

  it "stocks an item to a tray" do
    @tray = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray)
    results = ItemMultiplex.call(@item.id, @tray.barcode)
    expect(results[:error]).to eq(nil)
    expect(results[:notice]).to eq("Item #{@item.barcode} stocked.")
    expect(results[:path]).to eq(items_path)
  end

  it "rejects a wrong tray scan" do
    @tray = FactoryGirl.create(:tray)
    @tray2 = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray)
    results = ItemMultiplex.call(@item.id, @tray2.barcode)
    expect(results[:error]).to eq("incorrect tray for this item")
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(show_item_path(:id => @item.id))
  end


  it "rejects scanning a shelf" do
    @tray = FactoryGirl.create(:tray)
    @shelf = FactoryGirl.create(:shelf)
    @item = FactoryGirl.create(:item, tray: @tray)
    results = ItemMultiplex.call(@item.id, @shelf.barcode)
    expect(results[:error]).to eq("scan either a new item or a tray to stock to")
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(show_item_path(:id => @item.id))
  end


end
