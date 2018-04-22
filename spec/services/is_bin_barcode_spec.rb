require 'rails_helper'

RSpec.describe IsBinBarcode do

  it "recognizes 'BIN-ILL-LOAN-01' as a valid barcode" do
    barcode = 'BIN-ILL-LOAN-01'
    expect(IsBinBarcode.call(barcode)).to eq(true)
  end

  it "recognizes 'BIN-ILL-SCAN-01' as a valid barcode" do
    barcode = 'BIN-ILL-SCAN-01'
    expect(IsBinBarcode.call(barcode)).to eq(true)
  end

  it "recognizes 'BIN-ALEPH-LOAN-01' as a valid barcode" do
    barcode = 'BIN-ALEPH-LOAN-01'
    expect(IsBinBarcode.call(barcode)).to eq(true)
  end

  it "recognizes 'BIN-REM-STOCK-01' as a valid barcode" do
    barcode = 'BIN-REM-STOCK-01'
    expect(IsBinBarcode.call(barcode)).to eq(true)
  end

  it "recognizes 'BIN-REM-HAND-01' as a valid barcode" do
    barcode = 'BIN-REM-HAND-01'
    expect(IsBinBarcode.call(barcode)).to eq(true)
  end

  it "indicates 'SHELF-1234' is an invalid barcode" do
    barcode = 'SHELF-1234'
    expect(IsBinBarcode.call(barcode)).to eq(false)
  end
end
