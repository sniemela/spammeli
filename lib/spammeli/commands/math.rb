module Spammeli
  module Commands
    class Math < Spammeli::Command
      def invoke
        formula = params.join
        
        begin
          unless formula =~ /^[0-9\(\)\+\-\/\*\%\.]+$/
            raise ArgumentError
          end
        
          result = eval(formula)
          raise ZeroDivisionError if result =~ /divided by 0/
          
          result
        rescue ArgumentError
          "The formula may contain some illegal characters"
        rescue ZeroDivisionError
          "Zero division :/"
        end
      end
    end
  end
end