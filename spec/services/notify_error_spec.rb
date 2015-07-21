require "rails_helper"

RSpec.describe NotifyError do
  let(:exception) { instance_double(StandardError) }
  let(:args) { { test: "test" } }

  subject { described_class.call(exception: exception, args: args) }

  it "calls Airbrake#notify" do
    expect(Airbrake).to receive(:notify).with(exception, parameters: { args: args })
    subject
  end
end
