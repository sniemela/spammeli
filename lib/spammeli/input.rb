module Spammeli
  class Input
    attr_reader :body, :type, :channel, :message, :nick
    
    def initialize(input)
      @body = input.strip
      @type, @channel, @message, @nick = nil
      
      parse_input
    end
    
    def command?
      message =~ /^!\w+/
    end
    
    def ping?
      type == 'PING'
    end
    
    def authenticated?
      message == 'NO_IDENT_RESPONSE'
    end
    
    private
      def parse_input
        case body
        when /:(.+)!(.+)@(.+)\sPRIVMSG\s(.+)\s:(.+)/
          @nick, @channel, @message, @type = $1, $4, $5, 'PRIVMSG'
        when /^PING :(.+)$/
          @message, @type = $1, 'PING'
        when /^NOTICE AUTH \:\*\*\* No ident response$/
          @message = 'NO_IDENT_RESPONSE'
        end
      end
  end
end