module Spammeli
  class Input
    attr_reader :body, :type
    
    def initialize(input)
      @body = input
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
        case body.strip
        when /^!\w+/ then 'command'
        end
      end
  end
end