require 'socket'

module Spammeli
  class Irc
    attr_reader :server, :port, :connection, :channels, :nick, :realname
    
    def initialize(s, p, nick, realname, channels = [])
      @server, @port = s, p
      @connection = nil
      @channels = channels
      @nick = nick
      @realname = realname
      @joined = false
    end
    
    def connect!
      @connection = TCPSocket.open(server, port) unless connected?
      authenticate
    end
    
    def connected?
      !@connection.nil? && !@connection.closed?
    end
    
    def join_to_channels
      if connected?
        send_output("JOIN #{channels.join(',')}")
        @joined = true
      end
    end
    
    def authenticate
      if connected?
        send_output "USER #{nick} 8 * : #{realname}"
        send_output "NICK #{nick}"
      end
    end
    
    def send_output(output)
      puts "=> Sending output\n\t#{output}"
      @connection.send("#{output}\n", 0)
    end
    
    def run!
      puts "Starting IRC BOT..."
      puts "Press CTRL-C to terminate."
      connect!
      
      begin
        while input = connection.gets
          begin
            input = Spammeli::Input.new(input)
            buffer = Spammeli::Output.new(@connection, input)
            buffer.send
            
            if input.authenticated?
              join_to_channels unless @joined
            end
          rescue Spammeli::UnknownCommand => e
            buffer.send_to_channel("I don't know how to handle the command #{e.message}. Maybe you could extend me?")
          rescue Spammeli::InvalidCommand
            buffer.send_to_channel("Ouch, that command is registered but it doesn't have the invoke method.")
          rescue Exception => e
            puts "Outch: " + e.message
            buffer.send_to_channel("Ouch, something bad happened!")
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
  end
end