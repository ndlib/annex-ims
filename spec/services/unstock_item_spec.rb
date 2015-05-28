require 'rails_helper'

RSpec.describe UnstockItem do
  subject { described_class.call(item)}
  let(:item) { double(Item, "unstocked" => false, save: true, "unstocked!" => nil)} # insert used methods

  before(:each) do
    allow(IsObjectItem).to receive(:call).with(item).and_return(true)
  end

  it "sets stocked" do
    expect(item).to receive("unstocked!")
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

end
