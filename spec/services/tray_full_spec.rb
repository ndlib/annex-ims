require 'rails_helper'

RSpec.describe TrayFull do

  # These first tests are written on the assumption that size A trays have a capacity of 40. If that changes, these must change.
  it "indicates that a tray that is definitely not full shows as not full" do
    @tray = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray, thickness: 1)
    results = TrayFull.call(@tray)
    expect(results).to eq(false)
  end

  it "indicates that a tray that is definitely full shows as full" do
    @tray = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray, thickness: 10)
    @item2 = FactoryGirl.create(:item, tray: @tray, thickness: 10)
    @item3 = FactoryGirl.create(:item, tray: @tray, thickness: 10)
    @item4 = FactoryGirl.create(:item, tray: @tray, thickness: 10)
    @item5 = FactoryGirl.create(:item, tray: @tray, thickness: 10)
    results = TrayFull.call(@tray)
    expect(results).to eq(true)
  end

  it "indicates that a tray that is barely full shows as full" do
    @tray = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray, thickness: 9)
    @item2 = FactoryGirl.create(:item, tray: @tray, thickness: 6)
    @item3 = FactoryGirl.create(:item, tray: @tray, thickness: 5)
    @item4 = FactoryGirl.create(:item, tray: @tray, thickness: 10)
    @item5 = FactoryGirl.create(:item, tray: @tray, thickness: 10)
    @item6 = FactoryGirl.create(:item, tray: @tray, thickness: 6)
    results = TrayFull.call(@tray)
    expect(results).to eq(true)
  end

  # 11 items should have a capacity of 50, not 51 - add up to 51, it should be full
  it "verifies that the buffer is being used properly" do
    @tray = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray, thickness: 4)
    @item2 = FactoryGirl.create(:item, tray: @tray, thickness: 4)
    @item3 = FactoryGirl.create(:item, tray: @tray, thickness: 4)
    @item4 = FactoryGirl.create(:item, tray: @tray, thickness: 4)
    @item5 = FactoryGirl.create(:item, tray: @tray, thickness: 4)
    @item6 = FactoryGirl.create(:item, tray: @tray, thickness: 4)
    @item7 = FactoryGirl.create(:item, tray: @tray, thickness: 4)
    @item8 = FactoryGirl.create(:item, tray: @tray, thickness: 4)
    @item9 = FactoryGirl.create(:item, tray: @tray, thickness: 4)
    @item10 = FactoryGirl.create(:item, tray: @tray, thickness: 5)
    @item11 = FactoryGirl.create(:item, tray: @tray, thickness: 10)
    results = TrayFull.call(@tray)
    expect(results).to eq(true)
  end

  # Size E trays are going to be have a different capacity from A-D. I am guessing that to be 30 for now. Adjust accordingly.
  it "treats different size trays differently, barely full scenario" do
    @tray = FactoryGirl.create(:tray, barcode: "TRAY-EH12345")
    @item = FactoryGirl.create(:item, tray: @tray, thickness: 9)
    @item2 = FactoryGirl.create(:item, tray: @tray, thickness: 6)
    @item3 = FactoryGirl.create(:item, tray: @tray, thickness: 5)
    @item4 = FactoryGirl.create(:item, tray: @tray, thickness: 10)
    @item5 = FactoryGirl.create(:item, tray: @tray, thickness: 5)
    results = TrayFull.call(@tray)
    expect(results).to eq(true)
  end

  it "treats different size trays differently, almost full scenario" do
    @tray = FactoryGirl.create(:tray, barcode: "TRAY-EH12346")
    @item = FactoryGirl.create(:item, tray: @tray, thickness: 9)
    @item2 = FactoryGirl.create(:item, tray: @tray, thickness: 6)
    @item3 = FactoryGirl.create(:item, tray: @tray, thickness: 5)
    @item4 = FactoryGirl.create(:item, tray: @tray, thickness: 10)
    @item5 = FactoryGirl.create(:item, tray: @tray, thickness: 4)
    results = TrayFull.call(@tray)
    expect(results).to eq(false)
  end

end
