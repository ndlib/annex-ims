require "rails_helper"

RSpec.describe AnnexFaker::Tray do
  subject { described_class }

  it "generates a barcode" do
    expect(subject.barcode).to match(/^#{IsTrayBarcode::PREFIX}.*$/)
  end

  it "generates valid attributes" do
    object = Tray.new(subject.attributes)
    expect(object).to be_valid
  end
end
