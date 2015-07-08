module AnnexFaker
  class Base
  end

  class Letter
    ULetters = ("A".."Z").to_a

    class << self
      def uppercase_letters(number)
        ([nil]*number).map { uppercase_letter }.join
      end

      def uppercase_letters_alt(number)
        ([nil]*number).map { ULetters.sample }.join
      end

      def uppercase_letter
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
end
