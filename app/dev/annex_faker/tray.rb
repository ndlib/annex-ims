module AnnexFaker
  class Tray
    TRAY_LETTERS = ("A".."E").map do |a|
      ["H", "L"].map { |b| "#{a}#{b}"}
    end.flatten

    class << self
      def barcode
        "TRAY-#{TRAY_LETTERS.sample}#{AnnexFaker::Number.number(4)}"
      end

      def barcode_sequence(n)
        combinations = TRAY_LETTERS.count
        tray_number = (n.to_f / combinations).floor + 1
        tray_letter = TRAY_LETTERS.fetch(n % combinations)
        "TRAY-#{tray_letter}#{tray_number.to_s.rjust(4, '0')}"
      end

      def attributes
        {
          barcode: barcode
        }
      end
    end
  end
end
