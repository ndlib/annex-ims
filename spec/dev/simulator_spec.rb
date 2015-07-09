require "rails_helper"

RSpec.describe Simulator do
  subject { described_class.new }

  it "has a current_user" do
    expect(subject.current_user).to be_a_kind_of(User)
  end

  it "creates an item" do
    expect(subject.create_item).to be_a_kind_of(Item)
  end

  it "creates an item and logs the activity" do
    expect(ActivityLogger).to receive(:create_item).and_call_original
    expect(subject.create_and_log_item).to be_a_kind_of(Item)
  end

  it "creates a tray" do
    expect(subject.create_tray).to be_a_kind_of(Tray)
  end

  it "creates a user" do
    expect(subject.create_user).to be_a_kind_of(User)
  end

  it "creates a request" do
    expect(subject.create_request).to be_a_kind_of(Request)
  end

  context "benchmarks", benchmark: true do
    it "create_item" do
      iterations = 500

      simulator = subject

      Benchmark.bmbm(10) do |benchmark|
        benchmark.report "#{iterations} create_item" do
          iterations.times do |i|
            simulator.create_item
          end
          Item.delete_all
        end
      end
    end
  end
end
