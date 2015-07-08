module AnnexFaker
  class Bin
    BIN_TYPES = ["ILL-LOAN", "ILL-SCAN", "ALEPH-LOAN"]

    class << self
      def barcode
        "BIN-#{BIN_TYPES.sample}-#{AnnexFaker::Number.number(2)}"
      end

      def barcode_sequence(n)
        combinations = BIN_TYPES.count
        bin_number = (n.to_f / combinations).floor + 1
        bin_type = BIN_TYPES.fetch(n % combinations)
        "BIN-#{bin_type}-#{bin_number.to_s.rjust(2, '0')}"
      end

      def attributes
        {
          barcode: barcode
        }
      end
    end
  end
end
