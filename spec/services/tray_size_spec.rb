require 'rails_helper'

RSpec.describe TraySize do

  it "returns 'AL' for barcode 'TRAY-AL1234'" do
    barcode = 'TRAY-AL1234'
    expect(TraySize.call(barcode)).to eq('AL')
  end

end
