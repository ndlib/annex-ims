require 'spec_helper'

RSpec.describe UnresolvedIssueQuery do
  subject { described_class }
  let(:relation) { double }

  it 'will query for all issues that have not been resolved' do
    expect(relation).to receive(:where).with(resolved_at: nil)
    subject.call({}, relation: relation)
  end

  it 'will work with the default configuration' do
    issue = FactoryGirl.create(:issue)
    expect(subject.call({})).to eq([issue])
  end
end
