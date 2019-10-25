require "rails_helper"

RSpec.describe ScanItem do
  let(:item) { FactoryBot.create(:item, tray: tray) }
  let(:tray) { FactoryBot.create(:tray) }
  let(:user) { FactoryBot.create(:user) }
  let(:request) { FactoryBot.create(:request) }

  subject { described_class.call(item: item, request: request, user: user) }

  it "works" do
    subject
  end

  it "logs the scan activity" do
    expect(ActivityLogger).to receive(:scan_item).with(item: item, request: request, user: user)
    subject
  end
end
