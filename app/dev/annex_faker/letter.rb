module AnnexFaker
  class Letter
    ULETTERS = ("A".."Z").to_a

    class << self
      def uletters(number)
        ([nil]*number).map { ULETTERS.sample }.join
      end

      def uletter
        ULETTERS.sample
      end
    end
  end
end
