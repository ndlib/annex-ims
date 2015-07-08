require "rails_helper"

RSpec.describe AnnexFaker::Number do
  subject { described_class }

  it "generates a string of numbers" do
    expect(subject.number(4)).to match(/^[0-9]{4}$/)
  end

  it "benchmarks", benchmark: true do
    iterations = 100_000
    digits = 14

    Benchmark.bmbm(10) do |benchmark|
      if defined?(Faker)
        benchmark.report "Faker" do
          iterations.times do
            Faker::Number.number(digits)
          end
        end
      end

      benchmark.report "AnnexFaker" do
        iterations.times do
          AnnexFaker::Number.number(digits)
        end
      end
    end
  end
end
