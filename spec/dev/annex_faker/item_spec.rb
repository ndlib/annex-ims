require "rails_helper"

RSpec.describe AnnexFaker::Item do
  subject { described_class }

  it "generates a call number" do
    expect(subject.call_number).to match(/^[A-Z]{2}\d{4}[.][A-Z]\d{2} [0-2]?\d{3}$/)
  end

  it "generates a bib number" do
    expect(subject.bib_number).to match(/^\d+$/)
  end

  it "generates a barcode" do
    expect(subject.barcode).to match(/^\d{14}$/)
  end

  it "generates valid attributes" do
    object = Item.new(subject.attributes)
    expect(object).to be_valid
  end

  it "generates valid attributes in sequence" do
    object = Item.new(subject.attributes_sequence(1))
    expect(object).to be_valid
  end

  it "generates conditions" do
    conditions = subject.conditions
    expect(conditions.count).to be > 0
    conditions.each do |condition|
      expect(Item::CONDITIONS).to include(condition)
    end
  end

  it "generates an isbn" do
    expect(subject.isbn).to match(/^\d{9}-?[\d|X]$/)
  end

  it "generates an issn" do
    expect(subject.issn).to match(/^\d{4}-?\d{4}$/)
  end

  it "generates a title" do
    expect(subject.title).to match(/^[a-z ]+[.]$/i)
  end

  it "generates an author" do
    expect(subject.author).to match(/^[a-z .']+$/i)
  end
end
