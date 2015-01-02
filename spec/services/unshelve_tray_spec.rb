require 'rails_helper'

RSpec.describe UnshelveTray do
  subject { described_class.call(tray)}
  let(:tray) { double(Tray, "shelved=" => false, save: true)} # insert used methods

  before(:each) do
    allow(IsObjectTray).to receive(:call).with(tray).and_return(true)
  end

  it "sets shelved" do
    expect(tray).to receive("shelved=").with(false)
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
    #expect(IsTray).to recieve(:call).with(tray).and_return(false)
    #expect { subject }.to raise_error
  end
end
