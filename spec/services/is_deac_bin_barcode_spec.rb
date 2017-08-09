require 'rails_helper'

RSpec.describe IsDeacBinBarcode do

  it "recognizes 'BIN-DEAC-STOCK-01' as a valid barcode" do
    barcode = 'BIN-DEAC-STOCK-01'
    expect(IsDeacBinBarcode.call(barcode)).to eq(true)
  end

  it "recognizes 'BIN-DEAC-HAND-01' as a valid barcode" do
    barcode = 'BIN-DEAC-HAND-01'
    expect(IsDeacBinBarcode.call(barcode)).to eq(true)
  end

  it "indicates 'SHELF-1234' is an invalid barcode" do
    barcode = 'SHELF-1234'
    expect(IsBinBarcode.call(barcode)).to eq(false)
  end
end
