require "rails_helper"

RSpec.describe "Benchmark" do
  let(:iterations) { 100 }

  it "benchmarks items", disabled: true do
    Benchmark.bmbm(10) do |benchmark|
      benchmark.report "FactoryGirl" do
        iterations.times do
          FactoryGirl.create(:item)
        end
        Item.delete_all
      end

      benchmark.report "Item.create" do
        iterations.times do |i|
          Item.create!(
            barcode: "000012345#{i}",
            title: Faker::Lorem.sentence,
            author: Faker::Name.name,
            chron: "Vol 1",
            thickness: 1,
            tray: nil,
            bib_number: "0037612#{Faker::Number.number(2)}",
            isbn_issn: [true, false].sample ? Faker::Code.isbn : "#{Faker::Number.number(4)}-#{Faker::Number.number(4)}",
            conditions: [Item::CONDITIONS.sample, Item::CONDITIONS.sample, Item::CONDITIONS.sample, Item::CONDITIONS.sample].uniq,
            call_number: "#{("A".."Z").to_a.sample}#{("A".."Z").to_a.sample}#{Faker::Number.number(4)}.#{("A".."Z").to_a.sample}#{Faker::Number.number(2)} #{(1900..2014).to_a.sample}",
            initial_ingest: Faker::Date.between(2.days.ago, Date.today),
            last_ingest: Date::today.to_s,
            metadata_status: "complete",
          )
        end
        Item.delete_all
      end
    end
  end

  context "call_numbers" do
    let(:iterations) { 50_000 }
    let(:letters) { ("A".."Z").to_a }
    let(:years) { (1900..2014).to_a }

    it "benchmarks call numbers", disabled: true do
      Benchmark.bmbm(10) do |benchmark|
        benchmark.report "new" do
          iterations.times do
            "#{("A".."Z").to_a.sample}#{("A".."Z").to_a.sample}#{Faker::Number.number(4)}.#{("A".."Z").to_a.sample}#{Faker::Number.number(2)} #{(1900..2014).to_a.sample}"
          end
        end

        benchmark.report "let" do
          iterations.times do
            "#{letters.sample}#{letters.sample}#{Faker::Number.number(4)}.#{letters.sample}#{Faker::Number.number(2)} #{years.sample}"
          end
        end

        benchmark.report "init + calc" do
          iterations.times do
            "#{letters.sample}#{letters.sample}#{Faker::Number.number(4)}.#{letters.sample}#{Faker::Number.number(2)} #{years.sample}"
          end
        end
      end
    end

    context "numbers", disabled: true do
      let(:digits) { 14 }

      it "benchmarks" do
        Benchmark.bmbm(10) do |benchmark|
          benchmark.report "Faker" do
            iterations.times do
              Faker::Number.number(digits)
            end
          end

          # Fastest (10% of Faker)
          benchmark.report "custom" do
            iterations.times do
              rand(10 ** digits).to_s.rjust(digits, "0")
            end
          end
        end
      end
    end

    context "years", disabled: true do
      let(:iterations) { 500_000 }

      it "benchmarks" do
        init_years = (1900..2014).to_a
        Benchmark.bmbm(10) do |benchmark|
          benchmark.report "Years original" do
            iterations.times do
              (1900..2014).to_a.sample
            end
          end

          benchmark.report "let" do
            iterations.times do
              years.sample
            end
          end

          # Fastest (1.5% of original)
          benchmark.report "init" do
            iterations.times do
              init_years.sample
            end
          end

          benchmark.report "calc" do
            iterations.times do
              2015 - rand(115)
            end
          end
        end
      end
    end

    context "letters", disabled: true do
      let(:iterations) { 500_000 }

      it "benchmarks" do
        init_letters = ("A".."Z").to_a
        init_numbers = (65..90).to_a
        Benchmark.bmbm(10) do |benchmark|
          benchmark.report "Letters original" do
            iterations.times do
              ("A".."Z").to_a.sample
            end
          end

          benchmark.report "let" do
            iterations.times do
              letters.sample
            end
          end

          # Fastest (1.5% of original, tie with constant)
          benchmark.report "init" do
            iterations.times do
              init_letters.sample
            end
          end

          benchmark.report "init chr" do
            iterations.times do
              init_numbers.sample.chr
            end
          end

          # Fastest (1.5% of original, tie with init)
          benchmark.report "constant" do
            iterations.times do
              Faker::Base::ULetters.sample
            end
          end

          # Fastest (3.5% of original)
          benchmark.report "calc" do
            iterations.times do
              (rand(26) + 65).chr
            end
          end
        end
      end
    end
  end
end
