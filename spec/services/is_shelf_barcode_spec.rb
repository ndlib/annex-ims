require 'rails_helper'

RSpec.describe IsShelfBarcode do

  it "recognizes 'SHELF-1234' as a valid barcode" do
    barcode = 'SHELF-1234'
    expect(IsShelfBarcode.call(barcode)).to eq(true)
  end

  it "indicates 'TRAY-1234' is an invalid barcode" do
    barcode = 'TRAY-1234'
    expect(IsShelfBarcode.call(barcode)).to eq(false)
  end
end
