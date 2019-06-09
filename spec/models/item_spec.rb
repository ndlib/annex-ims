require "rails_helper"

RSpec.describe Item, type: :model do
  subject { described_class.new }

  describe "#metadata_status" do
    it "defaults to pending" do
      expect(subject.metadata_status).to eq("pending")
    end

    described_class::METADATA_STATUSES.each do |status|
      it "accepts the value #{status}" do
        subject.metadata_status = status
        subject.valid?
        expect(subject.errors[:metadata_status].size).to eq(0)
      end
    end

    it "does not accept other values" do
      subject.metadata_status = "test"
      subject.valid?
      expect(subject.errors[:metadata_status].size).to eq(1)
    end

    it "does not accept nil" do
      subject.metadata_status = nil
      subject.valid?
      expect(subject.errors[:metadata_status].size).to eq(1)
    end
  end

  it "does not accept barcodes with spaces" do
    subject.barcode = "12 34567"
    subject.valid?
    expect(subject.errors[:barcode].size).to eq(1)
  end
end
