require "rails_helper"

RSpec.describe ShelveTray do
  subject { described_class.call(tray, user) }
  let(:shelf) { double(Shelf) }
  let(:tray) { double(Tray, "shelved=" => true, save: true, shelf: shelf) } # insert used methods
  let(:user) { double(User, username: "bob", id: 1) }

  before(:each) do
    allow(ActivityLogger).to receive(:shelve_tray).with(tray: tray, shelf: shelf, user: user)
    allow(IsObjectTray).to receive(:call).with(tray).and_return(true)
  end

  it "sets shelved" do
    expect(tray).to receive("shelved=").with(true)
    subject
  end

  it "logs the activity" do
    expect(ActivityLogger).to receive(:shelve_tray).with(tray: tray, shelf: shelf, user: user)
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

  context "not a tray" do
    let(:tray) { instance_double(Item) }

    it "raises an error if the tray is not a tray." do
      expect(IsObjectTray).to receive(:call).with(tray).and_return(false)
      expect { subject }.to raise_error("object is not a tray")
    end
  end
end
