require 'rails_helper'

RSpec.describe IsTrayBarcode do

  it "recognizes 'TRAY-1234' as a valid barcode" do
    barcode = 'TRAY-1234'
    expect(IsTrayBarcode.call(barcode)).to eq(true)
  end

  it "indicates 'SHELF-1234' is an invalid barcode" do
    barcode = 'SHELF-1234'
    expect(IsTrayBarcode.call(barcode)).to eq(false)
  end
end
