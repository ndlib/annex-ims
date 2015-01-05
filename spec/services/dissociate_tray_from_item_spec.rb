require 'rails_helper'

RSpec.describe DissociateTrayFromItem do
  subject { described_class.call(item)}

  let(:tray) { double(Tray)}
  let(:item) { double(Item, save: true, "tray=" => nil)}

  before(:each) do
    allow(IsObjectItem).to receive(:call).with(item).and_return(true)
    allow(UnstockItem).to receive(:call).with(item).and_return(item)
  end

  it "removes the item" do
    expect(item).to receive("tray=")
    subject
  end

  it "saves the dissociated item" do
    expect(item).to receive(:save)
    subject
  end

  it "returns the item on success" do
    expect(item).to receive(:save).and_return(item)
    expect(subject).to be(item)
  end

  it "returns false on failure" do
    expect(item).to receive(:save).and_return(false)
    expect(subject).to be(false)
  end

  it "registers the call with the transaction log" do
    #expect(TransactionLog).to recieve(:call).with("dissociate", "itemid")
    #subject
  end
end
