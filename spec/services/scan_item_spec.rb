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

  it "logs the scan activity" do
    expect(ActivityLogger).to receive(:scan_item).with(item: item, request: request, user: user)
    subject
  end
end
