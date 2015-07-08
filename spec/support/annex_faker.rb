module AnnexFaker
  class Base
  end

  class Letter
    ULetters = ("A".."Z").to_a

    class << self
      def uletters(number)
        ([nil]*number).map { ULetters.sample }.join
      end

      def uletter
        ULetters.sample
      end
    end
  end

  class Number
    class << self
      def number(digits)
        rand(10 ** digits).to_s.rjust(digits, "0")
      end
    end
  end

  class Item
    YEARS = (1900..Date.today.year).to_a

    class << self
      def attributes
        {
          barcode: barcode,
          title: Faker::Lorem.sentence,
          author: Faker::Name.name,
          chron: "Vol 1",
          thickness: 1,
          tray: nil,
          bib_number: bib_number,
          isbn_issn: [true, false].sample ? isbn : issn,
          conditions: conditions,
          call_number: call_number,
          initial_ingest: Date.today - rand(3).days,
          last_ingest: Date.today,
          metadata_status: "complete",
        }
      end

      def attributes_sequence(i)
        {
          barcode: barcode_sequence(i),
          title: Faker::Lorem.sentence,
          author: Faker::Name.name,
          chron: "Vol 1",
          thickness: 1,
          tray: nil,
          bib_number: bib_number_sequence(i),
          isbn_issn: [true, false].sample ? isbn : issn,
          conditions: conditions,
          call_number: call_number,
          initial_ingest: Date.today - rand(3).days,
          last_ingest: Date.today,
          metadata_status: "complete",
        }
      end

      def call_number
        "#{AnnexFaker::Letter.uletters(2)}#{AnnexFaker::Number.number(4)}.#{AnnexFaker::Letter.uletter}#{AnnexFaker::Number.number(2)} #{YEARS.sample}"
      end

      def barcode
        "9#{AnnexFaker::Number.number(13)}"
      end

      def barcode_sequence(value)
        "8#{value.to_s.rjust(13, '0')}"
      end

      def bib_number(value = nil)
        "003#{AnnexFaker::Number.number(7)}"
      end

      def bib_number_sequence(value)
        "004#{value.to_s.rjust(7, '0')}"
      end

      def conditions
        ([nil] * (rand(4) + 1)).map { ::Item::CONDITIONS.sample }.uniq
      end

      def isbn
        Faker::Code.isbn
      end

      def issn
        "#{AnnexFaker::Number.number(4)}-#{AnnexFaker::Number.number(4)}"
      end
    end
  end
end
