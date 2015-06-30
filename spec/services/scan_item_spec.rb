require "rails_helper"

RSpec.describe ScanItem do
  let(:item) { FactoryGirl.create(:item, tray: tray) }
  let(:user) { FactoryGirl.create(:user) }
  let(:tray) { FactoryGirl.create(:tray) }

  subject { described_class.call(item, user) }

  it "works" do
    subject
  end

  it "unstocks the item and logs the scan activity" do
    expect(UnstockItem).to receive(:call).with(item, user)
    expect(LogActivity).to receive(:call).with(item, "Scanned", item.tray, anything, user)
    subject
  end
end
