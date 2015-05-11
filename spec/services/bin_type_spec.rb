require 'rails_helper'

RSpec.describe BinType do

  it "returns 'ILL-LOAN' for barcode 'BIN-ILL-LOAN-01'" do
    barcode = 'BIN-ILL-LOAN-01'
    expect(BinType.call(barcode)).to eq('ILL-LOAN')
  end

end
