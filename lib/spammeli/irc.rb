require 'socket'

module Spammeli
  class Irc
    attr_reader :server, :port, :connection
    
    def initialize(s, p)
      @server, @port = s, p
      @connection = nil
      @channel = "#tk08"
    end
    
    def connect!
      @connection = TCPSocket.open(server, port) unless connected?
    end
    
    def connected?
      !@connection.nil? && !@connection.closed?
    end
    
    def send_output(output)
      puts "=> Sending output\n\t#{output}"
      @connection.send("#{output}\n", 0)
    end
    
    def send_to_channel(output)
      send_output("PRIVMSG #{@channel} :#{output}")
    end
    
    def run!
      puts "Starting IRC BOT..."
      puts "Press CTRL-C to terminate."
      connect!
      
      send_output "USER spammeli 8 * : Spam Anneli"
      send_output "NICK spammeli"
      
      begin
        while input = connection.gets
          begin
            handle_input(input)
          rescue Spammeli::UnknownCommand => e
            send_to_channel("I don't know how to handle the command #{e.message}. Maybe you would extend me?")
          rescue Spammeli::InvalidCommand
            send_to_channel("Ouch, that command is registered but it doesn't have the invoke method.")
          rescue Exception => e
            puts "Outch: " + e.message
          end
        end
      rescue Interrupt
      end
      
      terminate!
    end
    
    def terminate!
      puts "Exiting..."
      if connected?
        send_output("QUIT :quitmo!")
        @connection.close
      end
      Kernel.exit
    end
    
    private
      # TODO: Clean this!
      def handle_input(input)
        case input.strip
        when /^PING :(.+)$/
          puts "=> Server Ping"
          send_output("PONG :#{$1}")
        when /End of \/MOTD command\./
          # This should be right time to join to channels
          send_output("JOIN #{@channel}")
        when /:(.+)!(.+)@(.+)\sPRIVMSG\s(.+)\s:(.+)/
          puts input
          input = Spammeli::Input.new($5)
          
          if input.command?
            send_output("PRIVMSG #{$4} :#{Spammeli::Command.invoke($5)}")
          end
        else
          puts input
        end
      end
  end
end