require "rails_helper"

RSpec.describe ResolveIssue do
  let(:item) { FactoryBot.create(:item) }
  let(:issue) { FactoryBot.create(:issue) }
  let(:user) { FactoryBot.create(:user) }
  subject { described_class.call(item: item, issue: issue, user: user) }

  it "resolves the issue" do
    expect(issue.resolved_at).to be_nil
    expect(issue.resolver).to be_nil
    subject
    expect(issue.resolved_at).to be >= Time.now - 1.second
    expect(issue.resolver).to eq(user)
  end

  it "logs the issue resolution" do
    expect(ActivityLogger).to receive(:resolve_issue).with(item: item, issue: issue, user: user)
    subject
  end
end
