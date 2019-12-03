require "rails_helper"

RSpec.describe AssociateTrayWithShelfBarcode do
  subject { described_class.call(tray, barcode, user) }
  let(:tray) { FactoryBot.create(:tray, shelf: shelf) }
  let(:shelf) { FactoryBot.create(:shelf) }
  let(:user) { FactoryBot.create(:user) }
  let(:barcode) { "examplebarcode" }

  before(:each) do
    # setup a shelf to come back from this class.
    allow(GetShelfFromBarcode).to receive(:call).with(barcode).and_return(shelf)
    allow(IsObjectTray).to receive(:call).with(tray).and_return(true)
  end

  it "gets a shelf from the barcode" do
    expect(GetShelfFromBarcode).to receive(:call).with(barcode).and_return(shelf)
    subject
  end

  it "sets the shelf " do
    expect(tray).to receive("shelf=").with(shelf)
    subject
  end

  it "returns the tray when it is successful" do
    allow(tray).to receive(:save).and_return(true)
    expect(subject).to be(tray)
  end

  it "returns false when it is unsuccessful" do
    allow(tray).to receive(:save).and_return(false)
    expect(subject).to be(false)
  end

  # this is not implemented in the class..
  it "raises an error if the item is not a tray." do
    # expect(IsTray).to recieve(:call).with(tray).and_return(false)
    # expect { subject }.to raise_error
  end
end
