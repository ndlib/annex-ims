require "rails_helper"

RSpec.describe AnnexFaker::Request do
  subject { described_class }

  it "allows setting of attributes" do
    attributes = subject.attributes(barcode: "1234", criteria: "12345")
    expect(attributes.fetch(:barcode)).to eq("1234")
    expect(attributes.fetch(:criteria)).to eq("12345")
  end

  context "aleph" do
    let(:source) { "aleph" }

    it "generates valid attributes" do
      object = Request.new(subject.attributes(source: source))
      expect(object).to be_valid
    end
  end

  context "illiad" do
    let(:source) { "illiad" }

    it "generates valid attributes" do
      object = Request.new(subject.attributes(source: source))
      expect(object).to be_valid
    end
  end
end
