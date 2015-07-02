require "rails_helper"

RSpec.describe ScanItem do
  let(:item) { FactoryGirl.create(:item, tray: tray) }
  let(:tray) { FactoryGirl.create(:tray) }
  let(:user) { FactoryGirl.create(:user) }
  let(:request) { FactoryGirl.create(:request) }

  subject { described_class.call(item: item, request: request, user: user) }

  it "works" do
    subject
  end

  it "unstocks the item and logs the scan activity" do
    expect(UnstockItem).to receive(:call).with(item, user)
    expect(ActivityLogger).to receive(:scan_item).with(item: item, request: request, user: user)
    subject
  end
end
