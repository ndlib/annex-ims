require "rails_helper"

RSpec.describe ShipItem do
  let(:item) { FactoryGirl.create(:item, tray: tray) }
  let(:user) { FactoryGirl.create(:user) }
  let(:tray) { FactoryGirl.create(:tray) }

  subject { described_class.call(item, user) }

  it "works" do
    subject
  end

  it "unstocks the item and logs the scan activity" do
    expect(LogActivity).to receive(:call).with(item, "Shipped", item.tray, anything, user)
    subject
  end
end
