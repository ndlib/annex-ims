module AnnexFaker
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
end
