require "rails_helper"

RSpec.describe TrayFull do
  before(:all) do
    FactoryBot.create(:tray_type)
    FactoryBot.create(:tray_type, code: "EH", capacity: 104)
  end

  # These first tests are written on the assumption that size A trays have a capacity of 136. If that changes, these must change.
  it "indicates that a tray that is definitely not full shows as not full" do
    @tray = FactoryBot.create(:tray)
    @item = FactoryBot.create(:item, tray: @tray, thickness: 1)
    results = TrayFull.call(@tray)
    expect(results).to eq(false)
  end

  it "indicates that a tray that is definitely full shows as full" do
    @tray = FactoryBot.create(:tray)
    @items = []
    15.times do
      @item = FactoryBot.create(:item, tray: @tray, thickness: 10)
      @items << @item
    end
    results = TrayFull.call(@tray)
    expect(results).to eq(true)
  end

  it "indicates that a tray that is barely full shows as full" do
    @tray = FactoryBot.create(:tray)
    @items = []
    14.times do
      @item = FactoryBot.create(:item, tray: @tray, thickness: 10)
      @items << @item
    end
    @item2 = FactoryBot.create(:item, tray: @tray, thickness: 6)
    results = TrayFull.call(@tray)
    expect(results).to eq(true)
  end

  # 11 items should have a capacity of 146, not 147 - add up to 147, it should be full
  it "verifies that the buffer is being used properly" do
    @tray = FactoryBot.create(:tray)
    @items = []
    14.times do
      @item = FactoryBot.create(:item, tray: @tray, thickness: 10)
      @items << @item
    end
    @item2 = FactoryBot.create(:item, tray: @tray, thickness: 7)
    results = TrayFull.call(@tray)
    expect(results).to eq(true)
  end

  # Size E trays are going to be have a different capacity from A-D, 104..
  it "treats different size trays differently, barely full scenario" do
    @tray = FactoryBot.create(:tray, barcode: "TRAY-EH12345")
    @items = []
    11.times do
      @item = FactoryBot.create(:item, tray: @tray, thickness: 10)
      @items << @item
    end
    @item2 = FactoryBot.create(:item, tray: @tray, thickness: 4)
    results = TrayFull.call(@tray)
    expect(results).to eq(true)
  end

  it "treats different size trays differently, almost full scenario" do
    @tray = FactoryBot.create(:tray, barcode: "TRAY-EH12346")
    @items = []
    11.times do
      @item = FactoryBot.create(:item, tray: @tray, thickness: 10)
      @items << @item
    end
    @item2 = FactoryBot.create(:item, tray: @tray, thickness: 3)
    results = TrayFull.call(@tray)
    expect(results).to eq(false)
  end
end
