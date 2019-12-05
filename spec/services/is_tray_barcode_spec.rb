require "rails_helper"

RSpec.describe IsTrayBarcode do
  before(:all) do
    FactoryBot.create(:tray_type)
    FactoryBot.create(:tray_type, code: "SHELF", unlimited: true)
  end

  it "recognizes 'TRAY-AL1234' as a valid barcode" do
    barcode = "TRAY-AL1234"
    expect(IsTrayBarcode.call(barcode)).to eq(true)
  end

  it "indicates 'SHELF-1234' is an invalid barcode" do
    barcode = "SHELF-1234"
    expect(IsTrayBarcode.call(barcode)).to eq(false)
  end

  it "accepts a special shelf/tray as a valid barcode" do
    barcode = "TRAY-SHELF-1234"
    expect(IsTrayBarcode.call(barcode)).to eq(true)
  end
end
