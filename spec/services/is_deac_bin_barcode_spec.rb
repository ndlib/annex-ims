require 'rails_helper'

RSpec.describe IsDeacBinBarcode do

  it "recognizes 'BIN-REM-STOCK-01' as a valid barcode" do
    barcode = 'BIN-REM-STOCK-01'
    expect(IsDeacBinBarcode.call(barcode)).to eq(true)
  end

  it "recognizes 'BIN-REM-HAND-01' as a valid barcode" do
    barcode = 'BIN-REM-HAND-01'
    expect(IsDeacBinBarcode.call(barcode)).to eq(true)
  end

  it "indicates 'SHELF-1234' is an invalid barcode" do
    barcode = 'SHELF-1234'
    expect(IsBinBarcode.call(barcode)).to eq(false)
  end
end
