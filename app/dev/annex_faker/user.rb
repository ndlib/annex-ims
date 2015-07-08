module AnnexFaker
  class User
    class << self
      def attributes
        {
          username: username
        }
      end

      def username
        "hallett#{AnnexFaker::Number.number(4)}"
      end

      def username_sequence(n)
        "hallett#{n.to_s.rjust(4, '0')}"
      end
    end
  end
end
