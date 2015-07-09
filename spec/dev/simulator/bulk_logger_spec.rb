require "rails_helper"

RSpec.describe Simulator::BulkLogger do
  let(:count) { 10 }
  subject { described_class.call(count: count) }

  it "inserts logs" do
    expect { subject }.to change { ActivityLog.count }.by(count)
  end

  context "benchmark", benchmark: true do
    let(:count) { 10_000 }

    subject { described_class.new(count: count) }

    it "inserts logs" do
      Benchmark.bmbm(10) do |benchmark|
        benchmark.report "BulkLogger" do
          count.times do
            subject.create_log!
          end
        end
      end
    end
  end
end
