require "rails_helper"

RSpec.describe AnnexFaker::User do
  subject { described_class }

  it "generates a username" do
    expect(subject.username).to match(/^hallett\d{4}$/)
  end

  it "generates valid attributes" do
    object = User.new(subject.attributes)
    expect(object).to be_valid
  end
end
