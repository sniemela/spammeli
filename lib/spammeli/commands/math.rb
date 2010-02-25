module Spammeli
  module Commands
    class Math < Spammeli::Command
      def invoke
        formula = params.join
        unless formula =~ /^[0-9\(\)\+\-\/\*\%\.]+$/
          return "The formula contains some illegal characters"
        end
        
        begin
          result = eval(formula)
          raise ZeroDivisionError if result =~ /divided by 0/
        
          result
        rescue ZeroDivisionError
          "Zero division :/"
        end
      end
    end
  end
end