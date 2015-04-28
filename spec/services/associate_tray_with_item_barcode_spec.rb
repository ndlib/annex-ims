require 'rails_helper'

RSpec.describe AssociateTrayWithItemBarcode do
  subject { described_class.call(user_id, tray, barcode, thickness)}
  let(:tray) { double(Tray, "item=" => true, save: true)} # insert used methods
  let(:item) { double(Item, "tray=" => true, "thickness=" => true, save: true, "stocked=" => true, initial_ingest: Date.today.to_s, last_ingest: Date.today.to_s)} # insert used methods
  let(:thickness) { Faker::Number.number(1) }
  let(:barcode) {  "examplebarcode" }
  let(:user_id) { 1 }

  before(:each) do
    # setup a shelf to come back from this class.
    allow(GetItemFromBarcode).to receive(:call).with(user_id, barcode).and_return(item)
    allow(IsObjectTray).to receive(:call).with(tray).and_return(true)
    allow(IsObjectItem).to receive(:call).with(item).and_return(true)
    allow(UpdateIngestDate).to receive(:call).with(item).and_return(true)
    @user_id = 1 # Just fake having a user here
  end


  it "gets an item from the barcode" do
    expect(GetItemFromBarcode).to receive(:call).with(user_id, barcode).and_return(item)
    subject
  end

  it "sets the item" do
    expect(item).to receive("tray=").with(tray)
    subject
  end

  it "returns the item when it is successful" do
    allow(item).to receive(:save).and_return(true)
    expect(subject).to be(item)
  end

  it "returns false when it is unsuccessful" do
    allow(item).to receive(:save).and_return(false)
    expect(subject).to be(false)
  end


# this is not implemented in the class..
  it "raises an error if the item is not a tray." do
    #expect(IsTray).to recieve(:call).with(tray).and_return(false)
    #expect { subject }.to raise_error
  end
end
