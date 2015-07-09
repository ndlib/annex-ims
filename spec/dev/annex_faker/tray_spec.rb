require "rails_helper"

RSpec.describe AnnexFaker::Tray do
  subject { described_class }
  let(:barcode_match) do
    /^#{IsTrayBarcode::PREFIX}.*$/
  end

  it "generates a barcode" do
    expect(subject.barcode).to match(barcode_match)
  end

  it "generates barcodes in sequence" do
    barcodes = (1..20).map { |i| subject.barcode_sequence(i) }
    expect(barcodes.uniq.count).to eq(20)
    barcodes.each do |barcode|
      expect(barcode).to match(barcode_match)
    end
  end

  it "generates valid attributes" do
    object = Tray.new(subject.attributes)
    expect(object).to be_valid
  end
end