require "rails_helper"

RSpec.describe DissociateShelfFromItem do
  subject { described_class.call(item, user) }

  let(:item) { instance_double(Item) }
  let(:user) { instance_double(User) }

  it "calls DissociateTrayFromItem" do
    expect(DissociateTrayFromItem).to receive(:call).with(item, user).and_return(true)
    expect(subject).to eq(true)
  end
end
