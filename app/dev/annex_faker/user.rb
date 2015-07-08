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
    end
  end
end
