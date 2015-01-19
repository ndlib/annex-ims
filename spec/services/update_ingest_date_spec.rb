require 'rails_helper'

RSpec.describe UpdateIngestDate do
  subject { described_class.call(item)}
  let(:item) { double(Item, "last_ingest=" => Date.today.to_s, initial_ingest: true, save: true)} # insert used methods

  before(:each) do
    allow(IsObjectItem).to receive(:call).with(item).and_return(true)
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
