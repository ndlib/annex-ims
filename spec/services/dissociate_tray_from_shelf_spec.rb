require 'rails_helper'

RSpec.describe DissociateTrayFromShelf do
  subject { described_class.call(tray, user)}

  let(:user) { FactoryGirl.create(:user) }
  let(:shelf) { FactoryGirl.create(:shelf) }
  let(:tray) { FactoryGirl.create(:tray, shelf: shelf) }

  before(:each) do
    allow(IsObjectTray).to receive(:call).with(tray).and_return(true)
    allow(UnshelveTray).to receive(:call).with(tray, user).and_return(tray)
  end

  it "removes the tray" do
    expect(tray).to receive("shelf=")
    subject
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

  it "logs the activity" do
    expect(ActivityLogger).to receive(:dissociate_tray_and_shelf).with(tray: tray, shelf: shelf, user: user)
    subject
  end
end
