require "rails_helper"

RSpec.describe AnnexFaker::User do
  subject { described_class }
  let(:username_match) do
    /^hallett\d{4}$/
  end

  it "generates a username" do
    expect(subject.username).to match(username_match)
  end

  it "generates usernames in sequence" do
    usernames = (1..10).map { |i| subject.username_sequence(i) }
    expect(usernames.uniq.count).to eq(10)
    usernames.each do |username|
      expect(username).to match(username_match)
    end
  end

  it "generates valid attributes" do
    object = User.new(subject.attributes)
    expect(object).to be_valid
  end
end
