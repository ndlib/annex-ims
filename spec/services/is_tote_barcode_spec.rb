require 'rails_helper'

RSpec.describe IsToteBarcode do

  it "recognizes 'TOTE-1234' as a valid barcode" do
    barcode = 'TOTE-1234'
    expect(IsToteBarcode.call(barcode)).to eq(true)
  end

  it "indicates 'SHELF-1234' is an invalid barcode" do
    barcode = 'SHELF-1234'
    expect(IsToteBarcode.call(barcode)).to eq(false)
  end
end
