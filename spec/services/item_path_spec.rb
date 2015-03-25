require 'rails_helper'

def h
  Rails.application.routes.url_helpers
end

RSpec.describe ItemPath do
  before(:each) do

  end

=begin
  it "runs a test and expect errors" do
    item_id = "03117208667242"
    barcode = "examplebarcode"
    results = ItemPath.call(item_id, barcode)
    expect(results[:error]).to eq("No item was found with barcode examplebarcode")
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(h.show_item_path(:id => item_id))
  end
=end

  it "returns a path for a valid item" do
    @tray = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray)
    results = ItemPath.call(@item.id, @item.barcode)
    expect(results[:error]).to eq(nil)
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(h.show_item_path(:id => @item.id))
  end

  it "returns a path for a valid second item" do
    @tray = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray)
    @item2 = FactoryGirl.create(:item, tray: @tray)
    results = ItemPath.call(@item.id, @item2.barcode)
    expect(results[:error]).to eq(nil)
    expect(results[:notice]).to eq(nil)
    expect(results[:path]).to eq(h.show_item_path(:id => @item2.id))
  end

end
