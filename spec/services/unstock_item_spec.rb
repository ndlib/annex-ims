require 'rails_helper'

RSpec.describe UnstockItem do
  subject { described_class.call(item, user)}
  let(:tray) { double(Tray, barcode: "TRAY-AH1234") }
  let(:item) { double(Item, "unstocked" => false, save: true, "unstocked!" => nil, tray: tray, barcode: "1234", "save!" => true)} # insert used methods
  let(:user) { double(User, username: "bob", id: 1)}

  before(:each) do
    allow(LogActivity).to receive(:call).and_return(true)
    allow(IsObjectItem).to receive(:call).with(item).and_return(true)
  end

  it "sets stocked" do
    expect(item).to receive("unstocked!")
    subject
  end

  it "returns the item when it is successful" do
    expect(subject).to be(item)
  end

  it "returns false when it is unsuccessful" do
    allow(item).to receive("save!").and_return(false)
    expect(subject).to be(false)
  end

end
