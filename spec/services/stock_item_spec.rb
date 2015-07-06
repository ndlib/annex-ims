require "rails_helper"

RSpec.describe StockItem do
  let(:item) { FactoryGirl.create(:item, tray: tray, thickness: 1) }
  let(:tray) { FactoryGirl.create(:tray) }
  let(:shelf) { FactoryGirl.create(:shelf) }
  let(:user) { FactoryGirl.create(:user) }
  subject { described_class.call(item, user) }

  it "sets stocked" do
    expect(item).to receive("stocked!")
    subject
  end

  it "logs the activity" do
    expect(ActivityLogger).to receive(:stock_item).with(item: item, tray: tray, user: user)
    subject
  end

  it "returns the item when it is successful" do
    allow(item).to receive(:save).and_return(true)
    expect(subject).to be(item)
  end

  it "returns false when it is unsuccessful" do
    allow(item).to receive("save!").and_return(false)
    expect(subject).to be(false)
  end

  it "queues a background job" do
    expect(ApiStockItemJob).to receive(:perform_later).with(item: item)
    subject
  end
end
