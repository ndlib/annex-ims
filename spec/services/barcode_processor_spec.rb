require 'rails_helper'

RSpec.describe BarcodeProcessor do
  subject { described_class.call(@tray, @barcode)}

# I'm not sure how to do this. If I use a mock class for tray, the processor will not work.
=begin
  before(:each) do
    @barcode = "SHELF-1234"
    @tray = Tray.new(barcode: "TRAY-A1234")
  end

  it "removes the tray" do
    expect(@tray).to receive("shelf=")
    subject
  end

  it "saves the associated tray" do
    expect(@tray).to receive(:save)
    subject
  end

  it "returns the tray on success" do
    expect(@tray).to receive(:save).and_return(true)
    expect(subject).to be(@tray)
  end

  it "returns false on failure" do
    expect(@tray).to receive(:save).and_return(false)
    expect(subject).to be(false)
  end
=end

  it "registers the call with the transaction log" do
    #expect(TransactionLog).to recieve(:call).with("dissociate", "itemid")
    #subject
  end
end
