require 'rails_helper'

RSpec.describe ShelfFull do
  before(:all) do
    FactoryGirl.create(:tray_type)
  end

  it "indicates that a shelf that is definitely not full shows as not full" do
    @tray = FactoryGirl.create(:tray)
    @shelf = FactoryGirl.create(:shelf)
    results = ShelfFull.call(@tray.tray_type, @shelf)
    expect(results).to eq(false)
  end

  it "indicates that a shelf that is definitely full shows as full" do
    @tray = FactoryGirl.create(:tray)
    @shelf = FactoryGirl.create(:shelf)
    (@tray.tray_type.trays_per_shelf + 1).times do
      FactoryGirl.create(:tray, shelf: @shelf)
    end
    results = ShelfFull.call(@tray.tray_type, @shelf)
    expect(results).to eq(true)
  end

  it "indicates that a shelf that is exactly full shows as full" do
    @tray = FactoryGirl.create(:tray)
    @shelf = FactoryGirl.create(:shelf)
    @tray.tray_type.trays_per_shelf.times do
      FactoryGirl.create(:tray, shelf: @shelf)
    end
    results = ShelfFull.call(@tray.tray_type, @shelf)
    expect(results).to eq(true)
  end
end
