require "rails_helper"

RSpec.describe "Benchmark" do
  let(:iterations) { 200 }

  context "items" do
    let(:iterations) { 1000 }
    it "benchmarks items", disabled: true do

      # RubyProf.start
      # iterations.times do |i|
      #   Item.create!(AnnexFaker::Item.attributes_sequence(i))
      # end
      # result = RubyProf.stop
      # printer = RubyProf::GraphHtmlPrinter.new(result)
      # File.open(Rails.root.join("tmp/profile_data.html"), "w") { |file| printer.print(file) }
      # Item.delete_all

      Benchmark.bmbm(10) do |benchmark|
        # benchmark.report "FactoryGirl" do
        #   iterations.times do
        #     FactoryGirl.create(:item)
        #   end
        #   Item.delete_all
        # end

        # benchmark.report "Item.create" do
        #   iterations.times do |i|
        #     Item.create!(
        #       barcode: "000012345#{i}",
        #       title: Faker::Lorem.sentence,
        #       author: Faker::Name.name,
        #       chron: "Vol 1",
        #       thickness: 1,
        #       tray: nil,
        #       bib_number: "0037612#{Faker::Number.number(2)}",
        #       isbn_issn: [true, false].sample ? Faker::Code.isbn : "#{Faker::Number.number(4)}-#{Faker::Number.number(4)}",
        #       conditions: [Item::CONDITIONS.sample, Item::CONDITIONS.sample, Item::CONDITIONS.sample, Item::CONDITIONS.sample].uniq,
        #       call_number: "#{("A".."Z").to_a.sample}#{("A".."Z").to_a.sample}#{Faker::Number.number(4)}.#{("A".."Z").to_a.sample}#{Faker::Number.number(2)} #{(1900..2014).to_a.sample}",
        #       initial_ingest: Faker::Date.between(2.days.ago, Date.today),
        #       last_ingest: Date::today.to_s,
        #       metadata_status: "complete",
        #     )
        #   end
        #   Item.delete_all
        # end

        benchmark.report "AnnexFaker Item.create" do
          iterations.times do |i|
            Item.create!(AnnexFaker::Item.attributes_sequence(i))
          end
          Item.delete_all
        end

        benchmark.report "AnnexFaker Item.save!" do
          iterations.times do |i|
            item = Item.new(AnnexFaker::Item.attributes_sequence(i))
            item.save!
          end
          Item.delete_all
        end

        benchmark.report "AnnexFaker Item.save! without validations" do
          iterations.times do |i|
            item = Item.new(AnnexFaker::Item.attributes_sequence(i))
            item.save!(validate: false)
          end
          Item.delete_all
        end

        benchmark.report "AnnexFaker build" do
          iterations.times do |i|
            Item.new(AnnexFaker::Item.attributes_sequence(i))
          end
        end
      end
    end
  end

  context "attributes" do
    let(:iterations) { 1000 }
    it "benchmarks items attributes", disabled: true do
      Benchmark.bmbm(10) do |benchmark|
        # benchmark.report "FactoryGirl.build" do
        #   iterations.times do
        #     FactoryGirl.build(:item)
        #   end
        # end

        # benchmark.report "Item.build" do
        #   iterations.times do |i|
        #     Item.new(
        #       barcode: "000012345#{i}",
        #       title: Faker::Lorem.sentence,
        #       author: Faker::Name.name,
        #       chron: "Vol 1",
        #       thickness: 1,
        #       tray: nil,
        #       bib_number: "0037612#{Faker::Number.number(2)}",
        #       isbn_issn: [true, false].sample ? Faker::Code.isbn : "#{Faker::Number.number(4)}-#{Faker::Number.number(4)}",
        #       conditions: [Item::CONDITIONS.sample, Item::CONDITIONS.sample, Item::CONDITIONS.sample, Item::CONDITIONS.sample].uniq,
        #       call_number: "#{("A".."Z").to_a.sample}#{("A".."Z").to_a.sample}#{Faker::Number.number(4)}.#{("A".."Z").to_a.sample}#{Faker::Number.number(2)} #{(1900..2014).to_a.sample}",
        #       initial_ingest: Faker::Date.between(2.days.ago, Date.today),
        #       last_ingest: Date::today.to_s,
        #       metadata_status: "complete",
        #     )
        #   end
        # end

        # benchmark.report "AnnexFaker build" do
        #   iterations.times do |i|
        #     Item.new(
        #       barcode: AnnexFaker::Item.barcode_sequence(i),
        #       title: Faker::Lorem.sentence,
        #       author: Faker::Name.name,
        #       chron: "Vol 1",
        #       thickness: 1,
        #       tray: nil,
        #       bib_number: AnnexFaker::Item.bib_number_sequence(i),
        #       isbn_issn: [true, false].sample ? AnnexFaker::Item.isbn : AnnexFaker::Item.issn,
        #       conditions: AnnexFaker::Item.conditions,
        #       call_number: AnnexFaker::Item.call_number,
        #       initial_ingest: Faker::Date.between(2.days.ago, Date.today),
        #       last_ingest: Date::today.to_s,
        #       metadata_status: "complete",
        #     )
        #   end
        # end

        benchmark.report "Original" do
          iterations.times do |i|
            {
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
            }
          end
        end

        benchmark.report "AnnexFaker attributes" do
          iterations.times do |i|
            {
              barcode: AnnexFaker::Item.barcode_sequence(i),
              title: Faker::Lorem.sentence,
              author: Faker::Name.name,
              chron: "Vol 1",
              thickness: 1,
              tray: nil,
              bib_number: AnnexFaker::Item.bib_number_sequence(i),
              isbn_issn: [true, false].sample ? AnnexFaker::Item.isbn : AnnexFaker::Item.issn,
              conditions: AnnexFaker::Item.conditions,
              call_number: AnnexFaker::Item.call_number,
              initial_ingest: Date.today - rand(3).days,
              last_ingest: Date.today,
              metadata_status: "complete",
            }
          end
        end

        benchmark.report "AnnexFaker#attributes" do
          iterations.times do |i|
            AnnexFaker::Item.attributes_sequence(i)
          end
        end

        benchmark.report "AnnexFaker small attributes" do
          iterations.times do |i|
            {
              barcode: AnnexFaker::Item.barcode_sequence(i),
              # title: Faker::Lorem.sentence,
              # author: Faker::Name.name,
              chron: "Vol 1",
              thickness: 1,
              tray: nil,
              bib_number: AnnexFaker::Item.bib_number_sequence(i),
              isbn_issn: [true, false].sample ? AnnexFaker::Item.isbn : AnnexFaker::Item.issn,
              conditions: AnnexFaker::Item.conditions,
              call_number: AnnexFaker::Item.call_number,
              # initial_ingest: Faker::Date.between(2.days.ago, Date.today),
              last_ingest: Date::today.to_s,
              metadata_status: "complete",
            }
          end
        end

        benchmark.report "Hash" do
          iterations.times do |i|
            {
              barcode: "AnnexFaker::Item.barcode_sequence(i)",
              title: "Faker::Lorem.sentence",
              author: "Faker::Name.name",
              chron: "Vol 1",
              thickness: 1,
              tray: nil,
              bib_number: "AnnexFaker::Item.bib_number_sequence(i)",
              isbn_issn: "[true, false].sample ? AnnexFaker::Item.isbn : AnnexFaker::Item.issn",
              conditions: "AnnexFaker::Item.conditions",
              call_number: "AnnexFaker::Item.call_number",
              initial_ingest: "Faker::Date.between(2.days.ago, Date.today)",
              last_ingest: "Date::today.to_s",
              metadata_status: "complete",
            }
          end
        end
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

        benchmark.report "AnnexFaker" do
          iterations.times do
            AnnexFaker::Item.call_number
          end
        end
      end
    end

    context "numbers", disabled: true do
      let(:iterations) { 150_000 }

      it "benchmarks" do
        digits = 14
        Benchmark.bmbm(10) do |benchmark|
          benchmark.report "Faker" do
            iterations.times do
              Faker::Number.number(digits)
            end
          end

          # Fastest (10% of Faker, tied with AnnexFaker)
          benchmark.report "custom" do
            iterations.times do
              rand(10 ** digits).to_s.rjust(digits, "0")
            end
          end

          # Fastest (10% of Faker, tied with custom)
          benchmark.report "AnnexFaker" do
            iterations.times do
              AnnexFaker::Number.number(digits)
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

    context "letter", disabled: true do
      let(:iterations) { 500_000 }

      it "benchmarks" do
        init_letters = ("A".."Z").to_a
        init_numbers = (65..90).to_a
        Benchmark.bmbm(10) do |benchmark|
          benchmark.report "Letter original" do
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
              AnnexFaker::Letter::ULetters.sample
            end
          end

          # Fastest (3.5% of original)
          benchmark.report "calc" do
            iterations.times do
              (rand(26) + 65).chr
            end
          end

          benchmark.report "AnnexFaker" do
            iterations.times do
              AnnexFaker::Letter.uletter
            end
          end
        end
      end
    end

    context "letters", disabled: true do
      let(:iterations) { 150_000 }

      it "benchmarks" do
        number_of_letters = 5
        init_letters = ("A".."Z").to_a
        init_numbers = (65..90).to_a
        Benchmark.bmbm(10) do |benchmark|
          benchmark.report "let" do
            iterations.times do
              ([nil]*number_of_letters).map { letters.sample }.join
            end
          end

          # Fastest
          benchmark.report "init" do
            iterations.times do
              ([nil]*number_of_letters).map { init_letters.sample }.join
            end
          end

          # Fastest
          benchmark.report "constant" do
            iterations.times do
              ([nil]*number_of_letters).map { AnnexFaker::Letter::ULetters.sample }.join
            end
          end

          benchmark.report "AnnexFaker" do
            iterations.times do
              AnnexFaker::Letter.uletters(5)
            end
          end
        end
      end
    end
  end
end
