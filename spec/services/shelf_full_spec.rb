require "rails_helper"

RSpec.describe ShelfFull do
  before(:all) do
    FactoryBot.create(:tray_type)
  end

  it "indicates that a shelf that is empty shows as empty" do
    @shelf = FactoryBot.create(:shelf)
    results = ShelfFull.call(@shelf)
    expect(results).to eq(ShelfFull::EMPTY)
  end

  it "indicates that a shelf that is definitely not full shows as not full" do
    @tray = FactoryBot.create(:tray)
    @shelf = FactoryBot.create(:shelf, trays: [@tray])
    results = ShelfFull.call(@shelf)
    expect(results).to eq(ShelfFull::PARTIAL)
  end

  it "indicates that a shelf that is exactly full shows as full" do
    @tray = FactoryBot.create(:tray)
    @shelf = FactoryBot.create(:shelf)
    @tray.tray_type.trays_per_shelf.times do
      FactoryBot.create(:tray, shelf: @shelf)
    end
    results = ShelfFull.call(@shelf)
    expect(results).to eq(ShelfFull::FULL)
  end

  it "indicates that a shelf that is over full shows as over" do
    @tray = FactoryBot.create(:tray)
    @shelf = FactoryBot.create(:shelf)
    (@tray.tray_type.trays_per_shelf + 1).times do
      FactoryBot.create(:tray, shelf: @shelf)
    end
    results = ShelfFull.call(@shelf)
    expect(results).to eq(ShelfFull::OVER)
  end
end
