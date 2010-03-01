module Spammeli
  class Output
    attr_reader :connection, :input, :out
    
    def initialize(connection, input)
      @connection, @input = connection, input
      @out = nil
    end
    
    def send
      @out = if input.command?
        out = benchmark do
          Spammeli::CommandRegistry.invoke(input.message)
        end
        
        message_for_channel(out)
      elsif input.ping?
        "PONG :#{input.message}"
      else
        puts input.body
      end
      
      send_to_connection(@out) if @out
    end
    
    def send_to_channel(message)
      send_to_connection(message_for_channel(message))
    end
    
    private
      def message_for_channel(message)
        "PRIVMSG #{input.channel} :#{message}"
      end
      
      def send_to_connection(output)
        puts "=> Sending output\n\t#{output}"
        @connection.send("#{output}\n", 0)
      end
      
      def benchmark(&block)
        start_time = Time.now
        result = block.call
        puts "Time elapsed: #{Time.now - start_time}"
        result
      end
  end
end