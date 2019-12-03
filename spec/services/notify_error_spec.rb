require "rails_helper"

RSpec.describe NotifyError do
  let(:exception) { instance_double(StandardError) }
  let(:parameters) { { test: "test" } }
  let(:component) { "component" }
  let(:action) { "action" }
  let(:expected_environment) { { environment: "environment" } }

  subject { described_class.call(exception: exception, parameters: parameters, component: component, action: action) }

  it "calls Raven#capture_exception" do
    expect(Raven).to receive(:capture_message).with(exception, extra: { component: component, action: action, parameters: parameters })
    subject
  end
end
