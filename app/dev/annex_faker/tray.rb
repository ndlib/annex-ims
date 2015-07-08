module AnnexFaker
  class Tray
    FIRST_LETTERS = ("A".."E").to_a
    SECOND_LETTERS = ["H", "L"]

    class << self
      def barcode
        "TRAY-#{FIRST_LETTERS.sample}#{SECOND_LETTERS.sample}#{AnnexFaker::Number.number(4)}"
      end

      def attributes
        {
          barcode: barcode
        }
      end
    end
  end
end
