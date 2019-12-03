require "rails_helper"

RSpec.describe UnshelveTray do
  subject { described_class.call(tray, user) }
  let(:shelf) { double(Shelf, barcode: "SHELF-1234") }
  let(:tray) { double(Tray, "shelved=" => false, save: true, shelf: shelf, barcode: "TRAY-AH1234") } # insert used methods
  let(:user) { double(User) }

  before(:each) do
    allow(ActivityLogger).to receive(:unshelve_tray).with(tray: tray, shelf: shelf, user: user)
    allow(IsObjectTray).to receive(:call).with(tray).and_return(true)
  end

  it "sets shelved" do
    expect(tray).to receive("shelved=").with(false)
    subject
  end

  it "logs the activity" do
    expect(ActivityLogger).to receive(:unshelve_tray).with(tray: tray, shelf: shelf, user: user)
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
