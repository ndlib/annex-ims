require 'rails_helper'

RSpec.describe DissociateTrayFromItem do
  subject { described_class.call(item, user)}

  let(:tray) { instance_double(Tray)}
  let(:item) { instance_double(Item, save: true, "tray=" => nil, tray: tray, "save!" => true)}
  let(:user) { instance_double(User, username: "bob", id: 1)}

  before(:each) do
    allow(ActivityLogger).to receive(:dissociate_item_and_tray).and_return(true)
    allow(IsObjectItem).to receive(:call).with(item).and_return(true)
    allow(UnstockItem).to receive(:call).with(item, user).and_return(item)
  end

  it "removes the item" do
    expect(item).to receive("tray=").with(nil)
    subject
  end

  it "saves the dissociated item" do
    expect(item).to receive("save")
    subject
  end

  it "returns the item on success" do
    expect(item).to receive("save").and_return(item)
    expect(subject).to be(item)
  end

  it "returns false on failure" do
    expect(item).to receive("save").and_return(false)
    expect(subject).to be(false)
  end

  it "logs the activity" do
    expect(ActivityLogger).to receive(:dissociate_item_and_tray).with(item: item, tray: tray, user: user)
    subject
  end
end
