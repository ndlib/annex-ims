require 'rails_helper'

RSpec.describe IsItemBarcode do

  it "recognizes '' as an invalid barcode" do
    expect(IsValidItem.call("")).to eq(false)
  end

  it "recognizes '123456789' as an invalid barcode" do
    expect(IsValidItem.call("123456789")).to eq(false)
  end

  it "recognizes '12345678901234' as a valid barcode" do
    barcode = "12345678901234"
    expect(IsValidItem.call(barcode)).to eq(true)
  end

  it "indicates 'SHELF-1234' is an invalid barcode" do
    barcode = "SHELF-1234"
    expect(IsValidItem.call(barcode)).to eq(false)
  end

  it "indicates 'BIN-ILL-LOAN-01' is an invalid barcode" do
    barcode = "BIN-ILL-LOAN-01"
    expect(IsValidItem.call(barcode)).to eq(false)
  end

  it "indicates 'TRAY-AL1234' is an invalid barcode" do
    barcode = "TRAY-AL1234"
    expect(IsValidItem.call(barcode)).to eq(false)
  end
end
