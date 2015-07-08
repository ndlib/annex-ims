module AnnexFaker
  class Number
    class << self
      def number(digits)
        rand(10 ** digits).to_s.rjust(digits, "0")
      end
    end
  end
end
