require "rails_helper"

RSpec.describe AnnexFaker::Letter do
  subject { described_class }

  it "generates a string of uppercase letters" do
    expect(subject.uletters(4)).to match(/^[A-Z]{4}$/)
  end

  it "generates a uppercase letter" do
    expect(subject.uletter).to match(/^[A-Z]$/)
  end
end
