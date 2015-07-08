module AnnexFaker
  class Shelf
    class << self
      HEIGHTS =
      def barcode
        "SHELF-#{AnnexFaker::Letter.uletter}-#{AnnexFaker::Number.number(3)}-#{AnnexFaker::Letter.uletter}"
      end

      def barcode_sequence(n)
        combinations = AnnexFaker::Letter::ULETTERS.count
        shelf_number = (n.to_f / combinations).floor + 1
        shelf_letter = AnnexFaker::Letter::ULETTERS.fetch(n % combinations)
        "SHELF-#{shelf_letter}-#{shelf_number.to_s.rjust(3, '0')}-#{AnnexFaker::Letter.uletter}"
      end

      def attributes
        {
          barcode: barcode
        }
      end
    end
  end
end
