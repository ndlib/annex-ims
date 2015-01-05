require 'rails_helper'

RSpec.describe IsItemBarcode do

  it "recognizes '12345678901234' as a valid barcode" do
    barcode = '12345678901234'
    expect(IsItemBarcode.call(barcode)).to eq(true)
  end

  it "indicates 'SHELF-1234' is an invalid barcode" do
    barcode = 'SHELF-1234'
    expect(IsItemBarcode.call(barcode)).to eq(false)
  end

  it "indicates 'TOTE-1234' is an invalid barcode" do
    barcode = 'TOTE-1234'
    expect(IsItemBarcode.call(barcode)).to eq(false)
  end

  it "indicates 'TRAY-A1234' is an invalid barcode" do
    barcode = 'TRAY-A1234'
    expect(IsItemBarcode.call(barcode)).to eq(false)
  end

end
