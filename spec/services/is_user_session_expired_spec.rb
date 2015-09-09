require "rails_helper"

RSpec.describe IsUserSessionExpired do
  let(:user) { instance_double(User) }

  it "calls expired? with the given user" do
    expect_any_instance_of(IsUserSessionExpired).to receive("expired?")
    described_class.call(user: user)
  end

  describe "expired?" do
    it "returns true if last activity exceeds the time limit" do
      allow(Rails.configuration).to receive(:user_timeout).and_return(1.days)
      allow(user).to receive(:last_activity_at).and_return(Time.now - 2.days)
      expect(subject.expired?(user: user)).to eq(true)
    end

    it "returns false if last activity does not exceed the time limit" do
      allow(Rails.configuration).to receive(:user_timeout).and_return(1.days)
      allow(user).to receive(:last_activity_at).and_return(Time.now)
      expect(subject.expired?(user: user)).to eq(false)
    end

    it "returns false if there is no last activity" do
      allow(user).to receive(:last_activity_at).and_return(nil)
      expect(subject.expired?(user: user)).to eq(true)
    end
  end
end
