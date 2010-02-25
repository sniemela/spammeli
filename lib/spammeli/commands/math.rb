module Spammeli
  module Commands
    class Math < Spammeli::Command
      def invoke
        formula = params.join
        
        unless formula =~ /^[0-9\(\)\+\-\/\*\%\.]+$/
          raise ArgumentError, "The formula may contain some illegal characters"
        end
        
        begin
          eval(formula)
        rescue Exception => e
          e.message
        end
      end
    end
  end
end