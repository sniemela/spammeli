module Spammeli
  module Commands
    class Math < Spammeli::Command
      def invoke
        eval(params.join)
      end
    end
  end
end