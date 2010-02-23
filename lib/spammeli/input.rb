module Spammeli
  class Input
    attr_reader :input, :type
    
    def initialize(input)
      @input = input
      @type = nil
    end
    
    def type
      @type ||= determine_type
    end
    
    def command?
      type == 'command'
    end
    
    private
      def determine_type
        case input
        when /^!\w+/ then 'command'
        end
      end
  end
end