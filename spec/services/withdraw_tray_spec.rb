require 'rails_helper'

RSpec.describe WithdrawTray do
  subject { described_class.call(tray)}

  let(:tray) { double(Tray, save: true, "shelf=" => nil, "shelved=" => false, items: [])}

  before(:each) do
    allow(IsObjectTray).to receive(:call).with(tray).and_return(true)
    allow(UnshelveTray).to receive(:call).with(tray).and_return(tray)
    allow(DissociateTrayFromShelf).to receive(:call).with(tray).and_return(tray)
  end

  it "saves the dissociated tray" do
    expect(tray).to receive(:save)
    subject
  end

  it "returns the tray on success" do
    expect(tray).to receive(:save).and_return(true)
    expect(subject).to be(tray)
  end

  it "returns false on failure" do
    expect(tray).to receive(:save).and_return(false)
    expect(subject).to be(false)
  end

  it "registers the call with the transaction log" do
    #expect(TransactionLog).to recieve(:call).with("dissociate", "itemid")
    #subject
  end
end
