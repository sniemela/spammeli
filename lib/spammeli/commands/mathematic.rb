module Spammeli
  module Commands
    class Mathematic
      include Cinch::Plugin

      MATH_FUNCTIONS = %w(
        acos acosh asin asinh atan atan2
        atanh cosh erf erfc exp frexp hypot
        ldexp log log10 sinh sqrt tan tanh sin cos
      ).sort

      match /math (.+)/
      plugin 'math'
      help "Syntax: !math <formula>. Available functions: #{MATH_FUNCTIONS.join(', ')}"

      def execute(m, formula)
        m.reply(calculate(formula))
      end

      def calculate(formula)
        formula = formula.gsub(/\s+/, '')

        math_methods = MATH_FUNCTIONS.join('|')
        unless formula =~ /^[0-9\(\)\+\-\/\*\%\.(#{math_methods})]+$/
          return "The formula contains some illegal characters"
        end

        begin
          formula = formula.gsub(/(#{math_methods})/, 'Math.\1')
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