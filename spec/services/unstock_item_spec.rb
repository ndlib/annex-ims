require 'rails_helper'

RSpec.describe UnstockItem do
  subject { described_class.call(item, user)}
  let(:tray) { double(Tray, barcode: "TRAY-AH1234") }
  let(:item) do
    instance_double(Item,
      unstocked?: false,
      save: true,
      "unstocked!" => nil,
      tray: tray,
      barcode: "1234",
      "save!" => true)
  end
  let(:user) { double(User, username: "bob", id: 1)}

  before(:each) do
    allow(ActivityLogger).to receive(:unstock_item)
    allow(IsObjectItem).to receive(:call).with(item).and_return(true)
  end

  it "sets stocked" do
    expect(item).to receive("unstocked!")
    subject
  end

  it "logs the activity" do
    expect(ActivityLogger).to receive(:unstock_item).with(item: item, tray: tray, user: user)
    subject
  end

  context "item already unstocked" do
    let(:item) do
      instance_double(Item,
        unstocked?: true,
        save: true,
        "unstocked!" => nil,
        tray: tray,
        barcode: "1234",
        "save!" => true)
    end

    it "doesn't log the activity if it was already stocked" do
      expect(ActivityLogger).not_to receive(:unstock_item).with(item: item, tray: tray, user: user)
      described_class.call(item, user)
    end
  end

  it "returns the item when it is successful" do
    expect(subject).to be(item)
  end

  it "returns false when it is unsuccessful" do
    allow(item).to receive("save!").and_return(false)
    expect(subject).to be(false)
  end

  context "no associated tray" do
    let(:tray) { nil }

    it "doesn't log the activity" do
      expect(ActivityLogger).not_to receive(:unstock_item).with(item: item, tray: tray, user: user)
      subject
    end

    it "still flags it as unstocked" do
      expect(item).to receive(:unstocked!)
      subject
    end
  end
end
