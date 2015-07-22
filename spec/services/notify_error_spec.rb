require "rails_helper"

RSpec.describe NotifyError do
  let(:exception) { instance_double(StandardError) }
  let(:parameters) { { test: "test" } }
  let(:component) { "component" }
  let(:action) { "action" }
  let(:expected_environment) { { environment: "environment" } }

  subject { described_class.call(exception: exception, parameters: parameters, component: component, action: action) }

  before do
    allow(described_class).to receive(:environment_info).and_return(expected_environment)
  end

  it "calls Airbrake#notify" do
    expect(Airbrake).to receive(:notify).with(exception, component: component, action: action, parameters: parameters, cgi_data: expected_environment)
    subject
  end

  context "environment_info" do
    subject { described_class.environment_info }

    before do
      allow(described_class).to receive(:environment_info).and_call_original
    end

    it "filters the environment data" do
      allow(Airbrake.configuration).to receive(:rake_environment_filters).and_return(["REJECT_KEY"])
      ENV["REJECT_KEY"] = "rejected"
      unfiltered_values = ENV.reject { false }
      filtered_values = ENV.reject { |k| k == "REJECT_KEY" }
      expect(subject).to_not eq(unfiltered_values)
      expect(subject).to eq(filtered_values)
    end
  end
end
