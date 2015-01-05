require 'rails_helper'

RSpec.describe TraySize do

  it "returns 'A' for barcode 'TRAY-A1234'" do
    barcode = 'TRAY-A1234'
    expect(TraySize.call(barcode)).to eq('A')
  end

end
